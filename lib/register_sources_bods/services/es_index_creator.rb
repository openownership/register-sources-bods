# frozen_string_literal: true

require 'json'

require_relative '../config/elasticsearch'

module RegisterSourcesBods
  module Services
    class EsIndexCreator
      MAPPINGS = JSON.parse(File.read(File.expand_path('mappings/mapping.json', __dir__)))

      def initialize(
        client: Config::ELASTICSEARCH_CLIENT,
        index: Config::ELASTICSEARCH_INDEX
      )
        @client = client
        @index = index
      end

      def create_index
        client.indices.create index:, body: { mappings: MAPPINGS }
      end

      private

      attr_reader :client, :index
    end
  end
end
