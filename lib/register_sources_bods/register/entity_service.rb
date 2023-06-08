require 'ostruct'
require 'register_sources_bods/enums/statement_types'
require 'register_sources_bods/register/statement_loader'
require 'register_sources_bods/register/entity_query_builder'
require 'register_sources_bods/register/paginated_array'

module RegisterSourcesBods
  module Register
    class EntityService
      def initialize(statement_repository:, entity_query_builder: EntityQueryBuilder.new)
        @entity_query_builder = entity_query_builder
        @statement_loader = StatementLoader.new(statement_repository:)
        @statement_repository = statement_repository
      end

      def search(search_params, exclude_identifiers: [], page: 1, per_page: 10)
        query = entity_query_builder.build_query(search_params, exclude_identifiers:)
        aggs = entity_query_builder.aggregations

        statements = statement_repository.search(query, aggs:, page:, per_page:)

        statement_ids = statements.map { |result| result.record.statementID }
        identifiers = statements.map(&:record).map(&:identifiers)

        result = statement_loader.load_statements(statement_ids)

        new_results = identifiers.map do |identifier|
          # result.entities[statement_id]&.master_entity || result.entities[statement_id] || result.relationships[statement_id]
          result.entities.values.find { |e| e.identifiers & identifier }
        end.compact.uniq # .map { |r|  OpenStruct.new(record: r) }

        Register::PaginatedArray.new(new_results, current_page: statements.current_page, records_per_page: statements.records_per_page, limit_value: nil, total_count: statements.total_count, aggs: statements.aggs)
      end

      def fallback_search(search_params, exclude_identifiers: [], page: 1, per_page: 10)
        query = entity_query_builder.build_fallback_query(search_params, exclude_identifiers:)
        aggs = entity_query_builder.aggregations

        statements = statement_repository.search(query, aggs:, page:, per_page:)

        statement_ids = statements.map { |result| result.record.statementID }

        result = statement_loader.load_statements(statement_ids)

        new_results = statement_ids.map do |statement_id|
          result.entities[statement_id]&.master_entity || result.entities[statement_id] || result.relationships[statement_id]
        end.compact.uniq # .map { |r|  OpenStruct.new(record: r) }

        Register::PaginatedArray.new(new_results, current_page: statements.current_page, records_per_page: statements.records_per_page, limit_value: nil, total_count: statements.total_count, aggs: statements.aggs)
      end

      def count_legal_entities
        # TODO: fix legal entities
        query = entity_query_builder.build_statement_type_query StatementTypes['entityStatement']

        statement_repository.count(query)
      end

      # merged_page, source_page

      def find(statement_id)
        result = statement_loader.load_statements([statement_id])

        result.entities[statement_id] || result.relationships[statement_id]
      end

      def find_by_entity_id(entity_id)
        find_by_entity_uri("/entities/#{entity_id}")
      end

      def find_by_entity_ids(entity_ids)
        find_by_entity_uris(entity_ids.map { |entity_id| "/entities/#{entity_id}" })
      end

      def find_by_entity_uri(uri)
        find_by_entity_uris([uri]).first
      end

      def find_by_entity_uris(uris)
        identifiers = uris.uniq.map do |uri|
          RegisterSourcesBods::Identifier[{
            id: uri,
            schemeName: "OpenOwnership Register",
            uri:,
          }]
        end

        records = statement_repository.list_matching_at_least_one_identifier(identifiers)

        statement_ids = records.map(&:statementID).uniq

        result = statement_loader.load_statements(statement_ids)

        statement_ids.map { |statement_id| result.entities[statement_id] || result.relationships[statement_id] }.compact
      end

      def list_matching_at_least_one_identifier(identifiers)
        records = statement_repository.list_matching_at_least_one_identifier(identifiers)

        statement_ids = records.map(&:statementID).uniq

        result = statement_loader.load_statements(statement_ids)

        statement_ids.map { |statement_id| result.entities[statement_id] || result.relationships[statement_id] }.compact
      end

      def list_for_subject_or_interested_party(**kwargs)
        records = statement_repository.list_for_subject_or_interested_party(**kwargs)

        statement_ids = records.map(&:statementID).uniq

        result = statement_loader.load_statements(statement_ids)

        statement_ids.map { |statement_id| result.entities[statement_id] || result.relationships[statement_id] }.compact
      end

      private

      attr_reader :entity_query_builder, :statement_repository, :statement_loader
    end
  end
end
