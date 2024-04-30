# frozen_string_literal: true

require 'json'
require 'logger'
require 'register_common/services/stream_client_kinesis'
require 'register_sources_oc/services/resolver_service'

require_relative '../services/publisher'

module RegisterSourcesBods
  module Apps
    class TransformerStream
      # rubocop:disable Metrics/ParameterLists
      def initialize(credentials:, consumer_id:, record_processor:, record_struct:, s3_adapter:, stream_name:)
        s3_bucket = ENV.fetch('BODS_S3_BUCKET_NAME')
        @logger = Logger.new($stdout)
        @stream_client = RegisterCommon::Services::StreamClientKinesis.new(
          credentials:, s3_adapter:, s3_bucket:, stream_name:, logger: @logger
        )
        @consumer_id = consumer_id
        @record_struct = record_struct
        entity_resolver = RegisterSourcesOc::Services::ResolverService.new
        bods_publisher = RegisterSourcesBods::Services::Publisher.new
        @bods_mapper = record_processor.new(entity_resolver:, bods_publisher:)
      end
      # rubocop:enable Metrics/ParameterLists

      def transform
        @stream_client.consume(@consumer_id) do |record_data|
          record_h = JSON.parse(record_data, symbolize_names: true)
          unless record_h[:company_number]
            match = %r{/company/(?<company_number>\w+)/}.match(record_h[:data][:links][:self])
            record_h[:company_number] = match[:company_number] if match
          end
          record = @record_struct[**record_h]
          @bods_mapper.process(record)
        end
      end
    end
  end
end
