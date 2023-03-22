
require 'register_sources_bods/repositories/bods_statement_repository'
# require 'register_sources_bods/services/records_producer'
require 'register_sources_bods/services/builder'
require 'register_sources_bods/services/id_generator'
require 'register_sources_bods/structs/bods_statement'

module RegisterSourcesBods
  module Services
    class Publisher
      def initialize(repository: nil, producer: nil, builder: nil, id_generator: nil)
        @repository = repository || RegisterSourcesBods::Repositories::BodsStatementRepository.new(
          client: RegisterSourcesBods::Config::ELASTICSEARCH_CLIENT)
        @producer = producer # || Services::RecordsProducer.new
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

        # Retrieve records with same identifiers or statement id
        all_identifiers = records.map { |record| record.respond_to?(:identifiers) ? record.identifiers : [] }.flatten
        records_for_all_identifiers = repository.list_matching_at_least_one_identifier(all_identifiers)

        # Retrieve records by statementID
        record_ids = records.map { |record| id_generator.generate_id record }.uniq
        remaining_record_ids = record_ids - records_for_all_identifiers.map(&:statementID)
        remaining_records = repository.get_bulk(record_ids)
        records_for_all_identifiers += remaining_records

        # Deduplicate into existing_records and pending_records
        existing_records = records.map do |record|
          records_for_all_identifiers.find do |existing_record|
            existing_record.statementID == id_generator.generate_id(record)
          end
        end.compact

        # Calculate records pending (not existing yet)
        existing_statement_ids = records_for_all_identifiers.map(&:statementID)
        pending_records = records.select { |record| !existing_statement_ids.include?(id_generator.generate_id(record)) }

        # Return early if there is nothing new to do
        return existing_records if pending_records.empty?

        # Build pending records, adding replaces statements for existing where necessary
        pending_ids = {}
        pending_records = pending_records.map do |record|
          records_for_identifiers = records_for_all_identifiers.select do |possible_record|
            next unless record.respond_to?(:identifiers)

            !(record.identifiers & possible_record.identifiers).empty?
          end

          pending_record = builder.build(record, records_for_identifiers)

          next if pending_ids[pending_record.statementID]
          pending_ids[pending_record.statementID] = true

          pending_record
        end.compact

        # Send pending records into stream
        producer.produce(pending_records)
        producer.finalize

        # Store pending records
        repository.store(pending_records)

        # Return all records
        existing_records + pending_records
      end

      private

      attr_reader :builder, :repository, :producer, :id_generator
    end
  end
end
