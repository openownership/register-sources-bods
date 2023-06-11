require 'ostruct'

require 'register_sources_bods/repositories/bods_statement_repository'
require 'register_sources_bods/services/builder'

module RegisterSourcesBods
  module Services
    class PendingRecords
      REGISTER_SCHEME_NAME = 'OpenOwnership Register'.freeze

      def initialize(repository: nil, builder: nil)
        @repository = repository || RegisterSourcesBods::Repositories::BodsStatementRepository.new(
          client: RegisterSourcesBods::Config::ELASTICSEARCH_CLIENT,
        )
        @builder = builder || Services::Builder.new
      end

      def build_all(records)
        return [] if records.empty?

        preprocessed = preprocess records

        r = process(preprocessed).map do |register_identifier, h|
          build(register_identifier, h[:pending], h[:existing])
        end.flatten

        print "Built records\n\n", r, "\n\n\n\n"

        r
      end

      private

      attr_reader :repository, :builder

      def preprocess(records)
        records.map do |record|
          identifiers = record.identifiers

          # Include source if it is a unique PSC one
          source = nil
          if record.source && (record.source.description == 'GB Persons Of Significant Control Register')
            if record.source.url != "http://download.companieshouse.gov.uk/en_pscdata.html"
              source = record.source
            end
          end

          OpenStruct.new(record:, identifiers:, source:)
        end
      end

      def process(pending_records)
        # fetch records for identifiers
        all_identifiers = pending_records.map(&:identifiers).flatten.uniq
        records_for_all_identifiers = repository.list_matching_at_least_one_identifier(all_identifiers).filter { |r| r.responds_to?(:identifiers) }

        # fetch records for sources
        all_sources = pending_records.map(&:source).compact
        records_for_all_sources = repository.list_matching_at_least_one_source(all_sources).filter { |r| r.responds_to?(:identifiers) }

        # put discovered records into groups using register id
        groups = {}

        (records_for_all_identifiers + records_for_all_sources).each do |related_record|
          register_identifier = find_register_identifier(related_record.identifiers)
          next unless register_identifier

          groups[register_identifier] ||= { pending: [], existing: [] }
          groups[register_identifier][:existing] << related_record
        end

        # calculate records in groups

        pending_records.each do |pending_record|
          # find register identifier from associated records
          related =
            (records_for_all_identifiers.map do |related_record|
              next unless related_record.identifiers & pending_record.identifiers

              find_register_identifier(related_record.identifiers)
            end) + (records_for_all_sources.map do |related_record|
              next unless pending_record.source && related_record.source && pending_record.source.url

              next unless related_record.source.url == pending_record.source.url

              find_register_identifier(related_record.identifiers)
            end)

          # construct register identifier unless one exists
          register_identifier = related.compact.first
          unless register_identifier
            built_record = builder.build(pending_record.record, replaces_ids: [])
            register_identifier = find_register_identifier(built_record.identifiers)
          end

          # add to existing or start new group for register identifier
          groups[register_identifier] ||= { pending: [], existing: [] }
          groups[register_identifier][:pending] << pending_record.record
        end

        print "Constructed groups: ", groups, "\n\n\n\n"
        groups
      end

      def build(register_identifier, pending, existing)
        # Calculate which of the statements are the latest (ie have never been replaced)
        replaced_statement_ids = Set.new(existing.map(&:replacesStatements).flatten.compact)
        unreplaced_statements = existing.reject { |statement| replaced_statement_ids.include? statement.statementID }.uniq
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

      def select_register_identifiers(identifiers)
        identifiers.filter { |identifier| identifier.schemeName == REGISTER_SCHEME_NAME }
      end

      def find_register_identifier(identifiers)
        select_register_identifiers(identifiers).sort.first
      end
    end
  end
end
