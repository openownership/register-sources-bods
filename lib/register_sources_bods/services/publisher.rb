
require 'register_sources_bods/repositories/bods_statement_repository'
require 'register_sources_bods/services/records_producer'
require 'register_sources_bods/services/builder'
require 'register_sources_bods/services/id_generator'
require 'register_sources_bods/structs/bods_statement'

module RegisterSourcesBods
  module Services
    class Publisher
      REGISTER_SCHEME_NAME = 'OpenOwnership Register'

      def initialize(repository: nil, producer: nil, builder: nil, id_generator: nil)
        @repository = repository || RegisterSourcesBods::Repositories::BodsStatementRepository.new(
          client: RegisterSourcesBods::Config::ELASTICSEARCH_CLIENT)
        @producer = producer || Services::RecordsProducer.new
        @builder = builder || Services::Builder.new
        @id_generator = id_generator || Services::IdGenerator.new
      end

      def publish(record)
        publish_many([record]).first
      end

      def publish_many(records)
        records = records.map { |record| BodsStatement[record.to_h.compact] }

        records_with_identifiers = records.filter { |r| r.respond_to?(:identifiers) }
        records_without_identifiers = records.filter { |r| !r.respond_to?(:identifiers) }

        (
          publish_records_with_identifiers(records_with_identifiers) +
          publish_records_without_identifiers(records_without_identifiers)
        )
      end

      private

      attr_reader :builder, :repository, :producer, :id_generator

      def publish_records_with_identifiers(records)
        return [] if records.empty?

        # Retrieve records with same identifiers
        all_identifiers = records.map { |record| record.respond_to?(:identifiers) ? record.identifiers : [] }.flatten
        records_for_all_identifiers = repository.list_matching_at_least_one_identifier(all_identifiers)

        # generate lists of identifiers
        identifier_links = {}

        # Add link to other identifiers
        (records_for_all_identifiers + records).each do |r|
          r.identifiers.to_a.each do |identifier|
            identifier_links[identifier] ||= Set.new
            r.identifiers.to_a.each do |identifier2|
              identifier_links[identifier] << identifier2
            end
          end
        end

        # Sort identifiers
        identifier_links = identifier_links.map do |identifier, linked|
          [identifier, linked.to_a.sort_by { |i| i.schemeName }]
        end.to_h

        # Associate records sharing an identifier
        records_by_identifier = {}

        [
          [records_for_all_identifiers, true],
          [records, false]
        ].each do |recs, published|
          recs.each do |r|
            first_identifier = r.identifiers.to_a.first

            next unless first_identifier

            identifier_index = identifier_links[first_identifier].first

            records_by_identifier[identifier_index] ||= {
              published: [], # TODO: republish if identifiers have changed
              pending: [],
              replaced: Set.new
            }

            records_by_identifier[identifier_index][published ? :published : :pending] << r

            if published
              r.replacesStatements.each do |statement_id|
                records_by_identifier[identifier_index][:replaced] << statement_id
              end
            end
          end
        end

        # Build records
        latest_records = []
        pending_records = []
        seen_statement_ids = {}

        records_by_identifier.each do |identifier_index, h|
          identifiers = identifier_links[identifier_index]

          # Any statement which never had its statementID included in a "replacesStatement" list
          # is a "latest" statement, which will need to be replaced.
          unreplaced_statement_ids = Set.new
          h[:published].each do |r|
            seen_statement_ids[r.statementID] = true

            next if h[:replaced].include?(r.statementID)

            unreplaced_statement_ids << r.statementID
          end

          h[:pending].each do |pending|
            # Update the list of identifiers in our pending record, in case other records
            # included additional identifiers that should still be tracked for this entity.
            pending = BodsStatement[pending.to_h.merge(identifiers: identifiers).compact]

            # Build our generated record, ready for publishing
            built = builder.build(pending, replaces_ids: unreplaced_statement_ids.to_a)

            # If the generated statementID has already been seen, this record can be safely.
            next if seen_statement_ids[built.statementID]

            # The builder will add the register identifier if one doesn't already exist in the list
            # In case this happened, the identifiers list is updated here to ensure subsequent records
            # include the same id
            identifiers = built.identifiers

            # This statement has replaced any existing statements and is now the latest
            unreplaced_statement_ids = Set.new([built.statementID])

            # Mark statement as seen so it is not published twice
            seen_statement_ids[built.statementID] = true

            # Add pending record to list to publish
            pending_records << built
          end

          # Keep track of the latest records (ie ones which have not been replaced)
          latest_records += (h[:published] + pending_records).filter { |r| unreplaced_statement_ids.include?(r.statementID) }
        end

        publish_new(pending_records)

        latest_records
      end

      def publish_records_without_identifiers(records)
        return [] if records.empty?

        # Retrieve records by statementID
        record_ids = records.map { |record| id_generator.generate_id record }.uniq

        # Fetch existing records from repository
        existing_records = repository.get_bulk(record_ids)

        # Reject records which had an id in the database
        existing_statement_ids = existing_records.map(&:statementID)
        pending_records = records.select { |record| !existing_statement_ids.include?(id_generator.generate_id(record)) }

        # Build pending records, adding replaces statements for existing where necessary
        pending_ids = {}
        pending_records = pending_records.map do |record|
          pending_record = builder.build(record)

          next if pending_ids[pending_record.statementID]
          pending_ids[pending_record.statementID] = true

          pending_record
        end.compact

        publish_new(pending_records)

        existing_records + pending_records
      end

      def publish_new(records)
        return if records.empty?

        # Send pending records into stream
        producer.produce(records)
        producer.finalize

        # Store pending records
        repository.store(records)
      end
    end
  end
end
