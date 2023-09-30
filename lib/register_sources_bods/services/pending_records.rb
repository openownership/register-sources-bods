# frozen_string_literal: true

require 'register_sources_bods/repositories/bods_statement_repository'
require 'register_sources_bods/services/builder'

module RegisterSourcesBods
  module Services
    class PendingRecords
      REGISTER_SCHEME_NAME = 'OpenOwnership Register'

      PreprocessedRecord = Struct.new(:uid, :record, :identifiers, :source)

      def initialize(repository: nil, builder: nil)
        @repository = repository || RegisterSourcesBods::Repositories::BodsStatementRepository.new(
          client: RegisterSourcesBods::Config::ELASTICSEARCH_CLIENT
        )
        @builder = builder || Services::Builder.new
      end

      # record = { uid: record }
      def build_all(records)
        return [] if records.empty?

        preprocessed = preprocess records

        process(preprocessed).map do |register_identifier, h|
          build(register_identifier, h[:pending], h[:existing]).merge(
            uids: h[:uids]
          )
        end.flatten
      end

      private

      attr_reader :repository, :builder

      def preprocess(records)
        records.map do |uid, record|
          identifiers = record.identifiers

          # Include source if it is a unique PSC one
          source = nil
          if record.source && (%r{https://api.company-information.service.gov.uk}.match record.source.url)
            source = record.source
          end

          PreprocessedRecord.new(uid, record, identifiers, source)
        end
      end

      # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      def process(pending_records)
        # fetch records for identifiers
        all_identifiers = pending_records.map(&:identifiers).flatten.uniq
        records_for_all_identifiers = repository.list_matching_at_least_one_identifier(all_identifiers).filter do |r|
          r.respond_to?(:identifiers)
        end

        # fetch records for sources
        all_sources = pending_records.map(&:source).compact.uniq
        records_for_all_sources = repository.list_matching_at_least_one_source(all_sources).filter do |r|
          r.respond_to?(:identifiers)
        end

        # put discovered records into groups using register id
        groups = {}

        (records_for_all_identifiers + records_for_all_sources).each do |related_record|
          register_identifier = find_register_identifier(related_record.identifiers)
          next unless register_identifier

          groups[register_identifier] ||= { pending: [], existing: [], uids: [] }
          groups[register_identifier][:existing] << related_record
        end

        # calculate records in groups

        pending_records.each do |pending_record|
          register_identifier = nil
          groups.each do |reg_id, group|
            sim_rec = (group[:existing] + group[:pending]).find do |rec|
              next unless rec.statementType == pending_record.record.statementType

              !(rec.identifiers & pending_record.record.identifiers).empty? || ( # rubocop:disable Style/ArrayIntersect
                pending_record.source &&
                rec.source &&
                pending_record.source.url &&
                (rec.source.url == pending_record.source.url)
              )
            end
            if sim_rec
              register_identifier = reg_id
              break
            end
          end

          # construct register identifier unless one exists
          unless register_identifier
            built_record = builder.build(pending_record.record, replaces_ids: [])
            register_identifier = find_register_identifier(built_record.identifiers)
          end

          # add to existing or start new group for register identifier
          groups[register_identifier] ||= { pending: [], existing: [], uids: [] }
          groups[register_identifier][:pending] << pending_record.record
          groups[register_identifier][:uids] << pending_record.uid
        end

        groups
      end
      # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

      # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      def build(register_identifier, pending, existing)
        # Calculate which of the statements are the latest (ie have never been replaced)
        replaced_statement_ids = Set.new(existing.map(&:replacesStatements).flatten.compact)
        unreplaced_statements = existing.reject do |statement|
          replaced_statement_ids.include? statement.statementID
        end.uniq
        seen_statement_ids = Set.new(existing.map(&:statementID))

        new_records = pending.map do |pending_record|
          # Construct new identifiers
          new_identifiers = (
            pending_record.identifiers +
            [register_identifier] +
            unreplaced_statements.map(&:identifiers)
          ).flatten.compact.uniq.sort_by { |i| i.schemeName || i.scheme }

          # Build new pending record
          pending_record = BodsStatement[pending_record.to_h.merge(identifiers: new_identifiers).compact]
          built_record = builder.build(pending_record, replaces_ids: unreplaced_statements.map(&:statementID))

          # Skip if this statement has already been seen
          next if seen_statement_ids.include? built_record.statementID

          seen_statement_ids << built_record.statementID

          # Update unreplaced statements to point to this one (as this is the new latest)
          unreplaced_statements = [built_record]

          built_record
        end.compact

        { new_records:, unreplaced_statements: }
      end
      # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

      def select_register_identifiers(identifiers)
        identifiers.filter { |identifier| identifier.schemeName == REGISTER_SCHEME_NAME }
      end

      def find_register_identifier(identifiers)
        select_register_identifiers(identifiers).min_by(&:id)
      end
    end
  end
end
