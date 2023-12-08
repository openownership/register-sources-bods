# frozen_string_literal: true

require 'active_support/core_ext/object/blank'
require 'register_common/services/bulk_transformer'
require 'register_common/services/publisher'

require_relative '../config/adapters'
require_relative '../logging'
require_relative '../record_deserializer'
require_relative '../record_serializer'
require_relative '../repositories/bods_statement_repository'
require_relative '../services/es_index_creator'

module RegisterSourcesBods
  module Ingester
    class IngestBulk
      BULK_NAMESPACE = 'BULK_INGESTER'

      def self.bash_call(args)
        s3_prefix, index, stream = args

        call(s3_prefix:, index:, stream:)
      end

      def self.call(s3_prefix:, index:, stream:)
        new(index:, stream:).call(s3_prefix)
      end

      # rubocop:disable Metrics/ParameterLists
      def initialize(
        bulk_transformer: nil,
        repository: nil,
        index: nil,
        publisher: nil,
        es_index_creator: nil,
        stream: nil
      )
        @bulk_transformer = bulk_transformer || RegisterCommon::Services::BulkTransformer.new(
          s3_adapter: Config::Adapters::S3_ADAPTER,
          s3_bucket: ENV.fetch('BODS_S3_BUCKET_NAME'),
          set_client: Config::Adapters::SET_CLIENT,
          namespace: BULK_NAMESPACE
        )
        @publisher = publisher || (stream && RegisterCommon::Services::Publisher.new(
          stream_name: stream,
          kinesis_adapter: Config::Adapters::KINESIS_ADAPTER,
          buffer_size: 25,
          serializer: RecordSerializer.new
        ))
        @deserializer = RecordDeserializer.new
        @repository = repository || Repositories::BodsStatementRepository.new(index:)
        @es_index_creator = es_index_creator || Services::EsIndexCreator.new(index:)
      end
      # rubocop:enable Metrics/ParameterLists

      def call(s3_prefix)
        es_index_creator.create_index_unless_exists

        bulk_transformer.call(s3_prefix) do |rows|
          process_rows rows
        end
      end

      private

      attr_reader :bulk_transformer, :deserializer, :repository, :publisher, :es_index_creator

      def process_rows(rows)
        records = rows.map do |row|
          record = deserializer.deserialize(row)
          Logging.log(record)
          record
        end

        new_records = records.reject { |record| repository.get(record.statementID) }

        return if new_records.empty?

        if publisher
          new_records.each do |record|
            publisher.publish(record)
          end

          publisher.finalize
        end

        repository.store(new_records, await_refresh: true)
      end
    end
  end
end
