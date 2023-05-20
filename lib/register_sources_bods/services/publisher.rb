
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
        return [] if records.empty?

        # Check records are Bods statements
        records = records.map { |record| BodsStatement[record.to_h.compact] }

        records_with_identifiers = records.filter { |r| r.respond_to?(:identifiers) }
        records_without_identifiers = records.filter { |r| !r.respond_to?(:identifiers) }

        # Process records

        (
          build_records_with_identifiers(records_with_identifiers) +
          build_records_without_identifiers(records_without_identifiers)
        )
      end

      private

      attr_reader :builder, :repository, :producer, :id_generator

      def build_records_with_identifiers(records)
        return if records.empty?

        # Retrieve records with same identifiers
        all_identifiers = records.map { |record| record.respond_to?(:identifiers) ? record.identifiers : [] }.flatten
        records_for_all_identifiers = repository.list_matching_at_least_one_identifier(all_identifiers)

        # generate lists of identifiers
        identifier_links = {}
        
        # Add link to other identifiers
        [records_for_all_identifiers, records].each do |r|
          r.identifiers.to_a.each do |identifier|
            identifiers.each do |identifier2|
              identifier_links[identifier] ||= Set.new
              identifier_links[identifier2] ||= Set.new
              identifier_links[identifier] << identifier2
              identifier_links[identifier2] << identifier
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
        ].each do |r, published|
          first_identifier = r.identifiers.to_a.first

          next unless first_identifier

          identifier_index = identifier_links[first_identifier].first

          records_by_identifier[identifier_index] ||= {
            published: [], # TODO: republish if identifiers have changed
            pending: []
          }

          key = published ? :published : :pending

          records_by_identifier[identifier_index][key] << r
        end

        # Build records
        pending_records = []
        all_records = []
        seen_statements = {}

        records_by_identifier.each do |identifier_index, h|
          identifiers = identifier_links[identifier_index]

          built_pending = []

          # Add published records to list of all records
          all_records += h[:published]

          h[:published].each { |published| seen_statements[published.statementID] = true }

          h[:pending].each do |pending|
            pending = BodsStatement[pending.to_h.merge(identifiers: identifiers).compact]

            built = builder.build(pending, h[:published] + built_pending)

            identifiers = built.identifiers # update our identifiers in case a register id was added

            next if seen_statements[built.statementID]

            seen_statements[built.statementID] = true
            built_pending << built
          end

          pending_records += built_pending
        end

        publish_new(pending_records)

        existing_records + pending_records
      end

      def build_records_without_identifiers(records)
        return if records.empty?

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
          pending_record = builder.build(record, [])

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
        producer.produce(pending_records)
        producer.finalize

        # Store pending records
        repository.store(pending_records)
      end
    end
  end
end
