# frozen_string_literal: true

require_relative '../repository'
require_relative '../structs/bods_statement'
require_relative 'builder'
require_relative 'pending_records'
require_relative 'records_producer'

module RegisterSourcesBods
  module Services
    class Publisher
      def initialize(repository: nil, producer: nil, builder: nil, pending_records_builder: nil, stream_name: nil)
        @repository = repository || RegisterSourcesBods::Repository.new(
          client: RegisterSourcesBods::Config::ELASTICSEARCH_CLIENT,
          index: RegisterSourcesBods::Config::ELASTICSEARCH_INDEX
        )
        @producer = producer || Services::RecordsProducer.new(stream_name:)
        @builder = builder || Services::Builder.new
        @pending_records_builder = pending_records_builder || Services::PendingRecords.new(
          repository: @repository
        )
      end

      def publish(record)
        publish_many({ uid: record }).values.first
      end

      def publish_many(records, identifiers_reject: nil)
        records = records.transform_values { |record| BodsStatement[record.to_h.compact] }

        records_with_identifiers = records.to_a.filter { |_uid, r| r.respond_to?(:identifiers) }.to_h
        records_without_identifiers = records.to_a.filter { |_uid, r| !r.respond_to?(:identifiers) }.to_h

        publish_records_with_identifiers(records_with_identifiers, identifiers_reject:).merge(
          publish_records_without_identifiers(records_without_identifiers)
        )
      end

      private

      attr_reader :builder, :repository, :producer, :pending_records_builder

      def publish_records_with_identifiers(records, identifiers_reject: nil)
        pending_records = pending_records_builder.build_all(records, identifiers_reject:)

        publishable_records = pending_records.map { |pend| pend[:new_records] }.flatten
        publish_new(deduplicate_existing_records(publishable_records))

        results = {}
        pending_records.each do |pend|
          pend[:uids].each do |uid|
            results[uid] = pend[:unreplaced_statements].first
          end
        end
        results
      end

      def publish_records_without_identifiers(records)
        pending_records = records.transform_values { |record| builder.build(record) }

        publishable_records = pending_records.values
        publish_new(deduplicate_existing_records(publishable_records))

        pending_records
      end

      def deduplicate_existing_records(records)
        return [] if records.empty?

        statement_ids = records.map(&:statementID).uniq

        existing_statements = repository.get_bulk(statement_ids)
        existing_statement_ids = Set.new(existing_statements.map(&:statementID))

        records.reject { |record| existing_statement_ids.include? record.statementID }
      end

      def publish_new(records)
        return if records.empty?

        # Send records into stream
        producer.produce(records)
        producer.finalize

        # Store pending records
        repository.store(records, await_refresh: true)
        repository.mark_replaced_statements(records)
      end
    end
  end
end
