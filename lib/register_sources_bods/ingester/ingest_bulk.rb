# frozen_string_literal: true

require 'register_common/services/bulk_transformer'
require 'register_common/services/publisher'

require 'register_sources_bods/config/adapters'
require 'register_sources_bods/record_deserializer'
require 'register_sources_bods/record_serializer'
require 'register_sources_bods/services/es_index_creator'
require 'register_sources_bods/repositories/bods_statement_repository'

module RegisterSourcesBods
  module Ingester
    class IngestBulk
      def self.bash_call(args)
        index = args[-2]
        s3_prefix = args[-1]

        call(index:, s3_prefix:)
      end

      def self.call(index:, s3_prefix:)
        new(index:).call(s3_prefix)
      end

      def initialize(
        bulk_transformer: nil,
        repository: nil,
        index: nil,
        publisher: nil,
        es_index_creator: nil
      )
        stream = ENV.fetch('BODS_STREAM', nil).presence

        @bulk_transformer = bulk_transformer || RegisterCommon::Services::BulkTransformer.new(
          s3_adapter: Config::Adapters::S3_ADAPTER,
          s3_bucket: ENV.fetch('BODS_S3_BUCKET_NAME'),
          set_client: Config::Adapters::SET_CLIENT
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

      def call(s3_prefix)
        es_index_creator.create_index_unless_exists

        bulk_transformer.call(s3_prefix) do |rows|
          process_rows rows
        end
      end

      private

      attr_reader :bulk_transformer, :deserializer, :repository, :publisher, :es_index_creator

      def process_rows(rows)
        records = rows.map do |record_data|
          deserializer.deserialize record_data
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
