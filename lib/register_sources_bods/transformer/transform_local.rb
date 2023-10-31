require 'register_sources_bods/config/adapters'
require 'register_sources_bods/record_deserializer'
require 'register_sources_bods/repositories/bods_statement_repository'
require 'register_sources_bods/services/publisher'
require 'register_sources_bods/services/es_index_creator'
require 'register_sources_oc/services/resolver_service'
require 'register_sources_bods/transformer/record_processor'

module RegisterSourcesBods
  module Transformer
    class TransformLocal
      def self.bash_call(args)
        raw_index = args[-3]
        dest_index = args[-2]
        local_path = args[-1]

        call(raw_index:, dest_index:, local_path:)
      end

      def self.call(raw_index:, dest_index:, local_path:)
        new(raw_index:, dest_index:).call(local_path)
      end

      def initialize(
        raw_records_repository: nil,
        records_repository: nil,
        record_processor: nil,
        raw_index: nil,
        dest_index: nil,
        deserializer: nil,
        entity_resolver: nil,
        bods_publisher: nil,
        es_index_creator: nil
      )
        entity_resolver ||= RegisterSourcesOc::Services::ResolverService.new

        @deserializer = deserializer || RecordDeserializer.new
        @raw_records_repository = raw_records_repository || Repositories::BodsStatementRepository.new(index: raw_index)
        @records_repository = records_repository || Repositories::BodsStatementRepository.new(index: dest_index, await_refresh: true)

        bods_publisher ||= RegisterSourcesBods::Services::Publisher.new(
          repository: @records_repository
        )
        @record_processor = record_processor || Transformer::RecordProcessor.new(
          entity_resolver:,
          raw_records_repository: @raw_records_repository,
          bods_publisher:
        )
        @es_index_creator = es_index_creator || Services::EsIndexCreator.new(index: dest_index)
      end

      def call(local_path)
        es_index_creator.create_index_unless_exists

        File.foreach(local_path) do |row|
          process_rows [row]
        end
      end

      private

      attr_reader :deserializer, :raw_records_repository, :records_repository, :record_processor, :es_index_creator

      def process_rows(rows)
        records = rows.map do |record_data|
          deserializer.deserialize record_data
        end

        record_processor.process_many records
      end
    end
  end
end
