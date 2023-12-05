# frozen_string_literal: true

require 'register_sources_oc/services/resolver_service'

require_relative '../constants/identifiers'
require_relative '../mappers/resolver_mappings'
require_relative '../repositories/bods_statement_repository'
require_relative '../services/publisher'
require_relative '../transformer/record_processor'
require_relative 'base'

module RegisterSourcesBods
  module Migrations
    class M20131205Resolve < Base
      include Mappers::ResolverMappings

      def initialize(identifiers_id_prefix = nil, index_raw = nil, index_dst = nil)
        super()
        @identifiers_id_prefix = identifiers_id_prefix || 'https://opencorporates.com/companies/gb/SC'
        @repo_dst = Repositories::BodsStatementRepository.new(index: index_dst, await_refresh: true)
        @repo_raw = Repositories::BodsStatementRepository.new(index: index_raw)
        @publisher = Services::Publisher.new(repository: @repo_dst)
        @resolver = RegisterSourcesOc::Services::ResolverService.new
        @processor = Transformer::RecordProcessor.new(bods_publisher: @publisher,
                                                      entity_resolver: @resolver,
                                                      raw_records_repository: @repo_raw)
      end

      private

      def do_migrate
        q_filter = {
          nested: {
            path: 'identifiers',
            query: {
              bool: {
                must: [
                  { term: { 'identifiers.schemeName': IDENTIFIER_NAME_OC } },
                  { prefix: { 'identifiers.id': @identifiers_id_prefix } }
                ]
              }
            }
          }
        }
        @repo_dst.each(q_filter:) do |doc|
          log_doc(doc)
          process_doc(doc)
        end
      end

      def process_doc(doc)
        stmt = BodsStatement[doc['_source'].compact]
        append_buffer(stmt)
      end

      def do_flush_buffer
        @buffer.each { |s| @processor.process(s) }
      end
    end
  end
end
