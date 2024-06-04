# frozen_string_literal: true

require 'json'
require 'logger'
require 'register_common/services/stream_client_kinesis'
require 'register_common/utils/expiring_set'
require 'register_sources_oc/services/resolver_service'

require_relative '../constants/redis'
require_relative '../services/publisher'

module RegisterSourcesBods
  module Apps
    class TransformerStream
      def initialize(credentials:, consumer_id:, namespace_transformed:, record_processor:, record_struct:,
                     s3_adapter:, stream_name:)
        s3_bucket = ENV.fetch('BODS_S3_BUCKET_NAME')
        @logger = Logger.new($stdout)
        @stream_client = RegisterCommon::Services::StreamClientKinesis.new(
          credentials:, s3_adapter:, s3_bucket:, stream_name:, logger: @logger
        )
        @consumer_id = consumer_id
        @record_struct = record_struct
        entity_resolver = RegisterSourcesOc::Services::ResolverService.new
        bods_publisher = Services::Publisher.new
        @bods_mapper = record_processor.new(entity_resolver:, bods_publisher:)
        redis = Redis.new(url: ENV.fetch('REDIS_URL'))
        @exp_set = RegisterCommon::Utils::ExpiringSet.new(
          redis:, namespace: namespace_transformed, ttl: REDIS_TRANSFORMED_TTL
        )
      end
      # rubocop:enable Metrics/ParameterLists

      def transform
        @stream_client.consume(@consumer_id) do |record_data|
          record_h = JSON.parse(record_data, symbolize_names: true)
          etag = record_h.dig(:data, :etag)
          unless record_h[:company_number]
            match = %r{/company/(?<company_number>\w+)/}.match(record_h[:data][:links][:self])
            record_h[:company_number] = match[:company_number] if match
          end
          next if etag && @exp_set.sismember(REDIS_TRANSFORMED_KEY, etag)

          record = @record_struct[**record_h]
          @bods_mapper.process(record)
          @exp_set.sadd(REDIS_TRANSFORMED_KEY, etag) if etag
        end
      end
    end
  end
end
