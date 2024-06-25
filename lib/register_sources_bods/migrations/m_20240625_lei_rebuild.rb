# frozen_string_literal: true

require_relative 'base'

module RegisterSourcesBods
  module Migrations
    class M20240625LEIRebuild < Base
      include Mappers::ResolverMappings

      def initialize(jurisdiction_codes = nil)
        super()
        @buffer_ids = Set.new
        @jurisdiction_codes = jurisdiction_codes&.split(',') || []
        @repo_bods = Repository.new(index: Config::ELASTICSEARCH_INDEX)
        @repo_ocai = RegisterSourcesOc::Repository.new(
          RegisterSourcesOc::AddId,
          index: RegisterSourcesOc::Config::ELASTICSEARCH_INDEX_ADD_IDS
        )
        @publisher = Services::Publisher.new
      end

      def do_migrate
        q_must = [
          { term: { identifier_system_code: 'lei' } },
          { terms: { jurisdiction_code: @jurisdiction_codes } }
        ]
        @repo_ocai.each(q_must:) do |doc|
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
        add_id = RegisterSourcesOc::AddId.new(doc['_source'])
        identifier = identifier_lei_from_add_id(add_id)
        stmt = stmt.new(identifiers: []) unless stmt.identifiers
        return if stmt.identifiers.include?(identifier)

        stmt.identifiers << identifier
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
