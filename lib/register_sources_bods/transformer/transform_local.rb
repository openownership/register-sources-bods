# frozen_string_literal: true

require 'register_sources_oc/services/resolver_service'

require_relative '../config/adapters'
require_relative '../logging'
require_relative '../record_deserializer'
require_relative '../repository'
require_relative '../services/es_index_creator'
require_relative '../services/publisher'
require_relative 'record_processor'

module RegisterSourcesBods
  module Transformer
    class TransformLocal
      def self.bash_call(args)
        local_path, raw_index, dest_index, stream, resolve = args
        stream  = nil if stream.blank?
        resolve = resolve.blank? || resolve.nil? ? nil : resolve != '0'

        call(raw_index:, dest_index:, local_path:, stream:, resolve:)
      end

      def self.call(raw_index:, dest_index:, local_path:, stream:, resolve:)
        new(raw_index:, dest_index:, stream:, resolve:).call(local_path)
      end

      def initialize(raw_index: nil, dest_index: nil, entity_resolver: nil, stream: nil, resolve: nil)
        resolve = true if resolve.nil?
        @deserializer = RecordDeserializer.new
        @raw_records_repository = Repository.new(index: raw_index)
        @records_repository = Repository.new(index: dest_index, await_refresh: true)

        entity_resolver ||= RegisterSourcesOc::Services::ResolverService.new if resolve
        @record_processor = Transformer::RecordProcessor.new(
          entity_resolver:,
          raw_records_repository: @raw_records_repository,
          bods_publisher: RegisterSourcesBods::Services::Publisher.new(
            repository: @records_repository,
            stream_name: stream
          )
        )
        @es_index_creator = Services::EsIndexCreator.new(index: dest_index)
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
        records = rows.map do |row|
          record = deserializer.deserialize(row)
          Logging.log(record)
          record
        end

        record_processor.process_many records
      end
    end
  end
end
