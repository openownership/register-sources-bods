# frozen_string_literal: true

require 'json'

require_relative '../config/elasticsearch'

module RegisterSourcesBods
  module Services
    class EsIndexCreator
      MAPPINGS = JSON.parse(File.read(File.expand_path('mappings/mapping.json', __dir__)))

      def initialize(client: Config::ELASTICSEARCH_CLIENT)
        @client = client
      end

      def create_index_unless_exists(index)
        create_index(index)
      rescue Elasticsearch::Transport::Transport::Errors::BadRequest => e
        raise e unless /resource_already_exists_exception/.match e.message
      end

      def create_index(index)
        client.indices.create index:, body: { mappings: MAPPINGS }
      end

      private

      attr_reader :client
    end
  end
end
