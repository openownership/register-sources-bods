# frozen_string_literal: true

require_relative 'base'

module RegisterSourcesBods
  module Migrations
    class M20240625LEIsRemove < Base
      include Mappers::ResolverMappings

      def initialize(identifier_scheme_name = nil)
        super()
        @repo_bods = Repository.new(index: Config::ELASTICSEARCH_INDEX)
        @publisher = Services::Publisher.new
        @identifiers_reject = ->(i) { i.schemeName == identifier_scheme_name }
      end

      def do_migrate
        q_must = {
          term: { statementType: 'entityStatement' }
        }
        q_filter = {
          nested: {
            path: 'identifiers',
            query: {
              bool: {
                must: [
                  { term: { 'identifiers.scheme': IDENTIFIER_SCHEME_LEI } }
                ]
              }
            }
          }
        }
        @repo_bods.each(q_must:, q_filter:) do |doc|
          log_doc(doc)
          process_doc(doc)
        end
      end

      def process_doc(doc)
        stmt = BodsStatement[doc['_source'].compact]
        append_buffer(stmt)
      end

      def do_flush_buffer
        stmts_h = @buffer.to_h { |s| [s.statementID, s] }
        @publisher.publish_many(stmts_h, identifiers_reject: @identifiers_reject)
      end
    end
  end
end
