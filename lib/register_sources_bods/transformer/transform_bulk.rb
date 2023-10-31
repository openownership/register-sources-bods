# frozen_string_literal: true

require 'register_common/services/bulk_transformer'

require 'register_sources_bods/config/adapters'
require 'register_sources_bods/record_deserializer'
require 'register_sources_bods/repositories/bods_statement_repository'
require 'register_sources_bods/services/publisher'
require 'register_sources_bods/services/es_index_creator'
require 'register_sources_oc/services/resolver_service'
require 'register_sources_bods/transformer/record_processor'

module RegisterSourcesBods
  module Transformer
    class TransformBulk
      def self.bash_call(args)
        raw_index = args[-3]
        dest_index = args[-2]
        s3_prefix = args[-1]

        call(raw_index:, dest_index:, s3_prefix:)
      end

      def self.call(raw_index:, dest_index:, s3_prefix:)
        new(raw_index:, dest_index:).call(s3_prefix)
      end

      def initialize(
        bulk_transformer: nil,
        raw_index: nil,
        dest_index: nil,
        entity_resolver: nil
      )
        @bulk_transformer = bulk_transformer || RegisterCommon::Services::BulkTransformer.new(
          s3_adapter: Config::Adapters::S3_ADAPTER,
          s3_bucket: ENV.fetch('BODS_S3_BUCKET_NAME'),
          set_client: Config::Adapters::SET_CLIENT
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
        records = rows.map do |record_data|
          deserializer.deserialize record_data
        end

        record_processor.process_many records
      end
    end
  end
end