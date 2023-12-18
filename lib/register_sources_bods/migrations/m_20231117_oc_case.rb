# frozen_string_literal: true

require_relative '../constants/identifiers'
require_relative '../mappers/resolver_mappings'
require_relative '../repositories/bods_statement_repository'
require_relative '../services/publisher'
require_relative 'base'

module RegisterSourcesBods
  module Migrations
    class M20231117OCCase < Base
      include RegisterSourcesBods::Mappers::ResolverMappings

      def initialize(identifiers_id_prefix = nil)
        super()
        @identifiers_id_prefix = identifiers_id_prefix || 'https://opencorporates.com/companies/gb/Sc'
        @repo = Repositories::BodsStatementRepository.new
        @publisher = Services::Publisher.new
        @identifiers_reject = lambda { |i|
          i.schemeName == IDENTIFIER_NAME_OC ? remap_identifier_open_corporates(i) != i : false
        }
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
        @repo.each(q_filter:) do |doc|
          log_doc(doc)
          process_doc(doc)
        end
      end

      def process_doc(doc)
        stmt = BodsStatement[doc['_source'].compact]
        identifiers2 = stmt.identifiers.map do |i|
          i.schemeName == IDENTIFIER_NAME_OC ? remap_identifier_open_corporates(i) : i
        end
        return if identifiers2 == stmt.identifiers

        stmt2 = stmt.new(identifiers: identifiers2)
        append_buffer(stmt2)
      end

      def do_flush_buffer
        stmts_h = @buffer.to_h { |s| [s.statementID, s] }
        @publisher.publish_many(stmts_h, identifiers_reject: @identifiers_reject)
      end
    end
  end
end
