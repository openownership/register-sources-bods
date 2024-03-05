# frozen_string_literal: true

require 'register_common/adapters/http_adapter'
require 'register_common/adapters/kinesis_adapter'
require 'register_common/adapters/redis_adapter'
require 'register_common/services/set_client_redis'
require 'register_common/adapters/s3_adapter'

require_relative 'settings'

module RegisterSourcesBods
  module Config
    module Adapters
      HTTP_ADAPTER    = RegisterCommon::Adapters::HttpAdapter.new
      KINESIS_ADAPTER = RegisterCommon::Adapters::KinesisAdapter.new(credentials: AWS_CREDENTIALS)
      S3_ADAPTER      = RegisterCommon::Adapters::S3Adapter.new(credentials: AWS_CREDENTIALS)
      REDIS_ADAPTER   = RegisterCommon::Adapters::RedisAdapter.new(url: ENV.fetch('REDIS_URL'))
      SET_CLIENT = RegisterCommon::Services::SetClientRedis.new(redis_adapter: REDIS_ADAPTER)
    end
  end
end
