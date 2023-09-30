# frozen_string_literal: true

require 'register_sources_bods/config/settings'
require 'register_sources_bods/config/adapters'
require 'register_sources_bods/record_serializer'
require 'register_common/services/publisher'

module RegisterSourcesBods
  module Services
    class RecordsProducer
      def initialize(stream_name: nil, kinesis_adapter: nil, buffer_size: nil, serializer: nil)
        stream_name ||= ENV.fetch('BODS_STREAM', nil)
        kinesis_adapter ||= RegisterSourcesBods::Config::Adapters::KINESIS_ADAPTER
        buffer_size ||= 50
        serializer ||= RecordSerializer.new

        @publisher = if stream_name
                       RegisterCommon::Services::Publisher.new(
                         stream_name:,
                         kinesis_adapter:,
                         buffer_size:,
                         serializer:
                       )
                     end
      end

      def produce(records)
        return unless publisher

        records.each do |record|
          publisher.publish(record)
        end
      end

      def finalize
        return unless publisher

        publisher.finalize
      end

      private

      attr_reader :publisher
    end
  end
end
