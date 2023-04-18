module RegisterSourcesBods
    module Register
        class EntityService
            def initialize(entity_searcher:, statement_repository:)
                @entity_searcher = entity_searcher
                @statement_repository = statement_repository
            end

            def find(statement_id)
                repository.get(statement_id)
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

                records = repository.list_matching_at_least_one_identifier(identifiers)

                # find record which hasn't been replaced
                replaced = records.flat_map { |record| record.replacesStatements }.compact.uniq

                records.filter { |record| !replaced.include?(record.statementID) }
            end

            def list_matching_at_least_one_identifier(identifiers)
                repository.list_matching_at_least_one_identifier(identifiers)
            end

            def list_for_subject_or_interested_party(**kwargs)
                repository.list_for_subject_or_interested_party(**kwargs)
            end

            private

            attr_reader :entity_searcher, :statement_repository
        end
    end
end
