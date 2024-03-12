# frozen_string_literal: true

require 'register_sources_oc/repositories/alt_name_repository'

require_relative '../mappers/resolver_mappings'
require_relative '../repository'
require_relative '../services/publisher'
require_relative 'base'

module RegisterSourcesBods
  module Migrations
    class M20231213AltNames < Base
      include RegisterSourcesBods::Mappers::ResolverMappings

      def initialize(jurisdiction_codes = nil, company_numbers = nil)
        super()
        @buffer_ids = Set.new
        @jurisdiction_codes = jurisdiction_codes&.split(',') || []
        @company_numbers = company_numbers&.split(',') || []
        @repo_ocan = RegisterSourcesOc::Repositories::AltNameRepository.new
        @repo_bods = Repository.new
        @publisher = Services::Publisher.new
      end

      private

      def do_migrate
        q = {
          jurisdiction_codes: @jurisdiction_codes,
          company_numbers: @company_numbers
        }
        @repo_ocan.each_alt_name(**q) do |doc|
          log_doc(doc)
          process_doc(doc)
        end
      end

      def process_doc(doc)
        id = identifier_open_corporates_from_company(
          doc['_source']['jurisdiction_code'], doc['_source']['company_number']
        )
        stmts = if @buffer_ids.member?(id)
                  [@buffer.find { |s| s.identifiers.include?(id) }]
                else
                  @repo_bods.list_matching_at_least_one_identifier([id], latest: true)
                end
        stmts.compact.each { |stmt| process_stmt(doc, id, stmt) }
      end

      def process_stmt(doc, id, stmt)
        alternate_name = doc['_source']['name']
        stmt = stmt.new(alternateNames: []) unless stmt.alternateNames
        return if stmt.alternateNames.include?(alternate_name)

        stmt.alternateNames << alternate_name
        return if @buffer_ids.member?(id)

        append_buffer(stmt)
        @buffer_ids.add(id)
      end

      def do_flush_buffer
        stmts_h = @buffer.to_h { |s| [s.statementID, s] }
        @publisher.publish_many(stmts_h)
        @buffer_ids = Set.new
      end
    end
  end
end
