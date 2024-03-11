# frozen_string_literal: true

require 'ostruct'
require 'register_common/utils/paginated_array'

require_relative '../constants/identifiers'
require_relative '../enums/statement_types'
require_relative 'entity_query_builder'
require_relative 'statement_loader'

module RegisterSourcesBods
  module Register
    class EntityService
      def initialize(statement_repository:, entity_query_builder: EntityQueryBuilder.new)
        @entity_query_builder = entity_query_builder
        @statement_loader = StatementLoader.new(statement_repository:)
        @statement_repository = statement_repository
      end

      # rubocop:disable Metrics/CyclomaticComplexity
      def search(search_params, exclude_identifiers: [], page: 1, per_page: 10)
        query = entity_query_builder.build_query(search_params, exclude_identifiers:)
        aggs = entity_query_builder.aggregations

        statements = statement_repository.search(query, aggs:, page:, per_page:)

        statement_ids = statements.map { |result| result.record.statementID }
        statements.map(&:record).map(&:identifiers)

        result = statement_loader.load_statements(statement_ids, max_levels: 1)

        new_results = statement_ids.map do |statement_id|
          result.entities[statement_id]&.master_entity ||
            result.entities[statement_id] ||
            result.relationships[statement_id]
        end.compact.uniq

        RegisterCommon::Utils::PaginatedArray.new(
          new_results,
          current_page: statements.current_page,
          records_per_page: statements.records_per_page,
          limit_value: nil,
          total_count: statements.total_count,
          aggs: statements.aggs
        )
      end
      # rubocop:enable Metrics/CyclomaticComplexity

      def fallback_search(search_params, exclude_identifiers: [], page: 1, per_page: 10)
        query = entity_query_builder.build_fallback_query(search_params, exclude_identifiers:)
        aggs = entity_query_builder.aggregations

        statements = statement_repository.search(query, aggs:, page:, per_page:)

        statement_ids = statements.map { |result| result.record.statementID }

        result = statement_loader.load_statements(statement_ids, max_levels: 1)

        new_results = statement_ids.map do |statement_id|
          result.entities[statement_id]&.master_entity ||
            result.entities[statement_id] ||
            result.relationships[statement_id]
        end.compact.uniq

        RegisterCommon::Utils::PaginatedArray.new(
          new_results,
          current_page: statements.current_page,
          records_per_page: statements.records_per_page,
          limit_value: nil,
          total_count: statements.total_count,
          aggs: statements.aggs
        )
      end

      def count_legal_entities
        # TODO: fix legal entities
        query = entity_query_builder.build_statement_type_query StatementTypes['entityStatement']

        statement_repository.count(query)
      end

      def find(statement_id)
        resolved_statement_id = statement_id.split('-unknown').first
        result = statement_loader.load_statements([resolved_statement_id])
        result.entities[statement_id] || result.relationships[statement_id]
      end

      def find_by_entity_id(entity_id)
        find_by_entity_uri("/entities/#{entity_id}")
      end

      def find_by_entity_uri(uri)
        results = find_by_entity_uris([uri])

        if /unknown/.match uri
          results.find { |result| /unknown/.match result.id }
        else
          results.find { |result| !(/unknown/.match result.id) }
        end
      end

      def find_by_entity_uris(uris)
        identifiers = uris.uniq.map do |uri|
          resolved_uri = uri.split('-unknown').first
          RegisterSourcesBods::Identifier[{
            id: resolved_uri,
            schemeName: IDENTIFIER_NAME_REG,
            uri: resolved_uri
          }]
        end

        records = statement_repository.list_matching_at_least_one_identifier(identifiers)

        statement_ids = records.map(&:statementID).uniq

        result = statement_loader.load_statements(statement_ids)

        statement_ids.map do |statement_id|
          [
            (result.entities[statement_id] || result.relationships[statement_id]),
            (result.entities["#{statement_id}-unknown"] || result.relationships["#{statement_id}-unknown"])
          ]
        end.flatten.compact
      end

      def list_matching_at_least_one_identifier(identifiers)
        records = statement_repository.list_matching_at_least_one_identifier(identifiers)

        statement_ids = records.map(&:statementID).uniq

        result = statement_loader.load_statements(statement_ids)

        statement_ids.map do |statement_id|
          result.entities[statement_id] || result.relationships[statement_id]
        end.compact
      end

      def list_for_subject_or_interested_party(**kwargs)
        records = statement_repository.list_for_subject_or_interested_party(**kwargs)

        statement_ids = records.map(&:statementID).uniq

        result = statement_loader.load_statements(statement_ids)

        statement_ids.map do |statement_id|
          result.entities[statement_id] || result.relationships[statement_id]
        end.compact
      end

      private

      attr_reader :entity_query_builder, :statement_repository, :statement_loader
    end
  end
end
