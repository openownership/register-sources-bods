require 'register_sources_bods/register/statement_loader'

module RegisterSourcesBods
    module Register
        class EntityService
            def initialize(entity_query_builder: nil, statement_repository:)
                @entity_query_builder = entity_query_builder
                @statement_loader = StatementLoader.new(statement_repository: statement_repository)
                @statement_repository = statement_repository
            end

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
                        uri: uri
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
