# frozen_string_literal: true

require_relative '../constants/identifiers'
require_relative '../repositories/bods_statement_repository'
require_relative 'base'

module RegisterSourcesBods
  module Migrations
    class M20131117OCCase < Base
      def initialize(identifiers_id_prefix = nil)
        super()
        @identifiers_id_prefix = identifiers_id_prefix || 'https://opencorporates.com/companies/gb/Sc'
        @repo = Repositories::BodsStatementRepository.new
      end

      def migrate
        q_filter = {
          nested: {
            path: 'identifiers',
            query: {
              bool: {
                must: [
                  { term: { 'identifiers.schemeName': OPEN_CORPORATES_SCHEME_NAME } },
                  { prefix: { 'identifiers.id': @identifiers_id_prefix } }
                ]
              }
            }
          }
        }
        @repo.each(q_filter:) do |doc|
          log_doc(doc)
        end
      end
    end
  end
end
