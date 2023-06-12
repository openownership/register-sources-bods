require 'securerandom'
require 'logger'
require 'register_sources_bods/repositories/bods_statement_repository'
require 'register_sources_bods/services/records_producer'
require 'register_sources_bods/services/builder'
require 'register_sources_bods/services/pending_records'
require 'register_sources_bods/services/id_generator'
require 'register_sources_bods/structs/bods_statement'

module RegisterSourcesBods
  module Services
    class Publisher
      def initialize(repository: nil, producer: nil, builder: nil, id_generator: nil)
        @repository = repository || RegisterSourcesBods::Repositories::BodsStatementRepository.new(
          client: RegisterSourcesBods::Config::ELASTICSEARCH_CLIENT,
        )
        @producer = producer || Services::RecordsProducer.new
        @builder = builder || Services::Builder.new
        @pending_records_builder = builder || Services::PendingRecords.new
        @id_generator = id_generator || Services::IdGenerator.new
        @logger = Logger.new($stdout)
        @cache = {}
      end

      def publish(record)
        publish_many([record]).first
      end

      def publish_many(records)
        records = records.map { |uid, record| [uid, BodsStatement[record.to_h.compact]] }.to_h

        records_with_identifiers = records.to_a.filter { |_uid, r| r.respond_to?(:identifiers) }.to_h
        records_without_identifiers = records.to_a.filter { |_uid, r| !r.respond_to?(:identifiers) }.to_h

        publish_records_with_identifiers(records_with_identifiers).merge(
          publish_records_without_identifiers(records_without_identifiers)
        )
      end

      private

      attr_reader :builder, :repository, :producer, :id_generator, :logger, :pending_records_builder

      def publish_records_with_identifiers(records)
        pending_records = pending_records_builder.build_all(records)

        publish_new(pending_records.map { |pend| pend[:new_records] }.flatten)

        results = {}
        pending_records.each do |pend|
          pend[:uids].each do |uid|
            results[uid] = pend[:unreplaced_statements].first
          end
        end
        results
      end

      def publish_records_without_identifiers(records)
        pending_records = records.map { |uid, record| [uid, builder.build(record)] }.to_h

        publish_new(pending_records.values)

        pending_records
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
