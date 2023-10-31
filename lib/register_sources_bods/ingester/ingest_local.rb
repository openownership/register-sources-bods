require 'register_common/services/publisher'

require 'register_sources_bods/config/adapters'
require 'register_sources_bods/record_deserializer'
require 'register_sources_bods/record_serializer'
require 'register_sources_bods/services/es_index_creator'
require 'register_sources_bods/repositories/bods_statement_repository'

module RegisterSourcesBods
  module Ingester
    class IngestLocal
      def self.bash_call(args)
        index = args[-2]
        local_path = args[-1]

        call(index:, local_path:)
      end

      def self.call(index:, local_path:)
        new(index:).call(local_path)
      end

      def initialize(
        repository: nil,
        index: nil,
        serializer: nil,
        deserializer: nil,
        publisher: nil,
        stream: nil,
        es_index_creator: nil
      )
        stream ||= ENV.fetch('BODS_STREAM', nil).presence
        @publisher = publisher || (stream && RegisterCommon::Services::Publisher.new(
          stream_name: stream,
          kinesis_adapter: Config::Adapters::KINESIS_ADAPTER,
          buffer_size: 25,
          serializer: (serializer || RecordSerializer.new),
        ))
        @deserializer = deserializer || RecordDeserializer.new
        @repository = repository || Repositories::BodsStatementRepository.new(index:)
        @es_index_creator = es_index_creator || Services::EsIndexCreator.new(index:)
      end

      def call(local_path)
        es_index_creator.create_index_unless_exists

        File.foreach(local_path) do |row|
          process_rows [row]
        end
      end

      private

      attr_reader :deserializer, :repository, :publisher, :es_index_creator

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

        print "Storing records: #{new_records}\n"
        repository.store(new_records)
      end
    end
  end
end
