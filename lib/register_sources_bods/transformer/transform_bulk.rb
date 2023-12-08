# frozen_string_literal: true

require 'register_common/services/bulk_transformer'
require 'register_common/services/publisher'
require 'register_sources_oc/services/resolver_service'

require_relative '../config/adapters'
require_relative '../logging'
require_relative '../record_deserializer'
require_relative '../record_serializer'
require_relative '../repositories/bods_statement_repository'
require_relative '../services/es_index_creator'
require_relative '../services/publisher'
require_relative 'record_processor'

module RegisterSourcesBods
  module Transformer
    class TransformBulk
      BULK_NAMESPACE = 'BULK_TRANSFORMER'

      def self.bash_call(args)
        s3_prefix, raw_index, dest_index, stream = args

        call(raw_index:, dest_index:, s3_prefix:, stream:)
      end

      def self.call(raw_index:, dest_index:, s3_prefix:, stream:)
        new(raw_index:, dest_index:, stream:).call(s3_prefix)
      end

      def initialize(
        bulk_transformer: nil,
        raw_index: nil,
        dest_index: nil,
        entity_resolver: nil,
        stream: nil
      )
        @bulk_transformer = bulk_transformer || RegisterCommon::Services::BulkTransformer.new(
          s3_adapter: Config::Adapters::S3_ADAPTER,
          s3_bucket: ENV.fetch('BODS_S3_BUCKET_NAME'),
          set_client: Config::Adapters::SET_CLIENT,
          namespace: BULK_NAMESPACE
        )
        @deserializer = RecordDeserializer.new
        @raw_records_repository = Repositories::BodsStatementRepository.new(index: raw_index)
        @records_repository = Repositories::BodsStatementRepository.new(index: dest_index, await_refresh: true)
        @es_index_creator = Services::EsIndexCreator.new(index: dest_index)

        entity_resolver ||= RegisterSourcesOc::Services::ResolverService.new
        @record_processor = Transformer::RecordProcessor.new(
          entity_resolver:,
          raw_records_repository: @raw_records_repository,
          bods_publisher: RegisterSourcesBods::Services::Publisher.new(
            repository: @records_repository
          )
        )
        return unless stream

        @publisher = RegisterCommon::Services::Publisher.new(
          stream_name: stream,
          kinesis_adapter: Config::Adapters::KINESIS_ADAPTER,
          buffer_size: 25,
          serializer: RecordSerializer.new
        )
      end

      def call(s3_prefix)
        es_index_creator.create_index_unless_exists

        bulk_transformer.call(s3_prefix) do |rows|
          process_rows rows
        end
      end

      private

      attr_reader :bulk_transformer, :deserializer, :raw_records_repository, :records_repository, :record_processor,
                  :es_index_creator

      def process_rows(rows)
        records = rows.map do |row|
          record = deserializer.deserialize(row)
          Logging.log(record)
          record
        end

        if @publisher
          new_records.each do |record|
            @publisher.publish(record)
          end
          @publisher.finalize
        end

        record_processor.process_many records
      end
    end
  end
end
