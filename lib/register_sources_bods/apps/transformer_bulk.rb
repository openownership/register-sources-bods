# frozen_string_literal: true

require 'json'
require 'redis'
require 'register_common/services/file_reader'
require 'register_common/utils/expiring_set'
require 'register_sources_oc/services/resolver_service'

require_relative '../constants/redis'
require_relative '../services/publisher'

module RegisterSourcesBods
  module Apps
    class TransformerBulk
      BATCH_SIZE = 25

      def initialize(namespace:, namespace_transformed:, parallel_files:, record_processor:, record_struct:,
                     s3_adapter:)
        @redis = Redis.new(url: ENV.fetch('REDIS_URL'))
        @s3_bucket = ENV.fetch('BODS_S3_BUCKET_NAME')
        @file_reader = RegisterCommon::Services::FileReader.new(
          s3_adapter:, batch_size: BATCH_SIZE
        )
        @record_struct = record_struct
        @s3_adapter = s3_adapter
        entity_resolver = RegisterSourcesOc::Services::ResolverService.new
        bods_publisher = Services::Publisher.new
        @bods_mapper = record_processor.new(entity_resolver:, bods_publisher:)
        @namespace = namespace
        @parallel_files = parallel_files
        @exp_set = RegisterCommon::Utils::ExpiringSet.new(
          redis: @redis, namespace: namespace_transformed, ttl: REDIS_TRANSFORMED_TTL
        )
      end

      def transform(s3_prefix)
        s3_paths = @s3_adapter.list_objects(s3_bucket: @s3_bucket, s3_prefix:)
        s3_paths.each_slice(@parallel_files) do |s3_paths_batch|
          threads = []
          s3_paths_batch.each do |s3_path|
            threads << Thread.new { process_s3_path(s3_path) }
          end
          threads.each(&:join)
        end
      end

      private

      def process_s3_path(s3_path)
        if file_processed?(s3_path)
          print "Skipping #{s3_path}\n"
          return
        end
        print "#{Time.now} Processing #{s3_path}\n"
        @file_reader.read_from_s3(s3_bucket: @s3_bucket, s3_path:) do |rows|
          process_rows rows
        end
        mark_file_complete(s3_path)
        print "#{Time.now} Completed #{s3_path}\n"
      end

      def process_rows(rows)
        rows.each do |record_data|
          record_h = JSON.parse(record_data, symbolize_names: true)
          next if @exp_set.sismember(REDIS_TRANSFORMED_KEY, record_h[:data][:etag])

          record = @record_struct[**record_h]
          @bods_mapper.process(record)
          @exp_set.sadd(REDIS_TRANSFORMED_KEY, record_h[:data][:etag])
        end
      end

      def file_processed?(s3_path)
        @redis.sismember(@namespace, s3_path)
      end

      def mark_file_complete(s3_path)
        @redis.sadd(@namespace, [s3_path])
      end
    end
  end
end
