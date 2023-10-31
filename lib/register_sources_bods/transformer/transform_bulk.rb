require 'register_common/services/bulk_transformer'

require 'register_sources_bods/config/adapters'
require 'register_sources_bods/record_deserializer'
require 'register_sources_bods/repositories/bods_statement_repository'
require 'register_sources_bods/services/publisher'
require 'register_sources_bods/services/es_index_creator'
require 'register_sources_oc/services/resolver_service'

module RegisterSourcesBods
  module Transformer
    module App
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
        raw_records_repository: nil,
        records_repository: nil,
        record_processor: nil,
        raw_index: nil,
        dest_index: nil,
        deserializer: nil,
        entity_resolver: nil,
        bods_publisher: nil
      )
        bods_publisher ||= RegisterSourcesBods::Services::Publisher.new
        entity_resolver ||= RegisterSourcesOc::Services::ResolverService.new

        @bulk_transformer = bulk_transformer || RegisterCommon::Services::BulkTransformer.new(
          s3_adapter: Config::Adapters::S3_ADAPTER,
          s3_bucket: s3_bucket || ENV.fetch('BODS_S3_BUCKET_NAME'),
          set_client: Config::Adapters::SET_CLIENT
        )
        @deserializer = deserializer || RecordDeserializer.new
        @raw_records_repository = raw_records_repository || Repositories::BodsStatementRepository.new(index: raw_index)
        @records_repository = records_repository || Repositories::BodsStatementRepository.new(index: dest_index, await_refresh: true)

        @record_processor = record_processor || Transformer::RecordProcessor.new(
          entity_resolver:,
          raw_records_repository: @raw_records_repository,
          bods_publisher:
        )
        @es_index_creator = es_index_creator || EsIndexCreator.new(es_index: dest_index)
      end

      def call(s3_prefix)
        es_index_creator.create_index_unless_exists

        bulk_transformer.call(s3_prefix) do |rows|
          process_rows rows
        end
      end

      private

      attr_reader :bulk_transformer, :deserializer, :raw_records_repository, :records_repository, :record_processor

      def process_rows(rows)
        records = rows.map do |record_data|
          deserializer.deserialize record_data
        end

        record_processor.process records
      end
    end
  end
end
