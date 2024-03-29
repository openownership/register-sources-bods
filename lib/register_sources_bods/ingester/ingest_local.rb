# frozen_string_literal: true

require 'active_support/core_ext/object/blank'
require 'register_common/services/publisher'

require_relative '../config/adapters'
require_relative '../logging'
require_relative '../record_deserializer'
require_relative '../record_serializer'
require_relative '../repository'
require_relative '../services/es_index_creator'

module RegisterSourcesBods
  module Ingester
    class IngestLocal
      def self.bash_call(args)
        local_path, index, stream = args

        call(local_path:, index:, stream:)
      end

      def self.call(local_path:, index:, stream:)
        new(index:, stream:).call(local_path)
      end

      def initialize(repository: nil, index: nil, publisher: nil, es_index_creator: nil, stream: nil)
        @publisher = publisher || (stream && RegisterCommon::Services::Publisher.new(
          stream_name: stream,
          kinesis_adapter: Config::Adapters::KINESIS_ADAPTER,
          buffer_size: 25,
          serializer: RecordSerializer.new
        ))
        @deserializer = RecordDeserializer.new
        @repository = repository || Repository.new(index:)
        @es_index_creator = es_index_creator || Services::EsIndexCreator.new
        @index = index
      end

      def call(local_path)
        es_index_creator.create_index_unless_exists(@index)

        File.foreach(local_path) do |row|
          process_rows [row]
        end
      end

      private

      attr_reader :deserializer, :repository, :publisher, :es_index_creator

      def process_rows(rows)
        records = rows.map do |row|
          record = deserializer.deserialize(row)
          Logging.log(record)
          record
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
