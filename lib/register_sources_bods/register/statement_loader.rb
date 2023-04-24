module RegisterSourcesBods
    module Register
        class StatementLoader
            def initialize(statement_repository:, statements_mapper:)
                @statement_repository = statement_repository
                @statements_mapper = statements_mapper
            end

            def load_statements(statement_ids)
                processed_ids = []

                all_statements = {}

                next_statement_ids = statement_ids.dup

                while !next_statement_ids.empty?
                    statements = single_loader(next_statement_ids, processed_ids: processed_ids)

                    all_statements.merge!(statement)

                    processed_ids = (processed_ids + next_statement_ids + statement.map(&:statementID)).uniq

                    next_statement_ids = []

                    next_statement_ids += statements.map(&:interestedParty).compact.map(&:describedByEntityStatement).compact
                    next_statement_ids += statements.map(&:interestedParty).compact.map(&:describedByPersonStatement).compact
                    next_statement_ids += statements.map(&:source).compact.map(&:describedByEntityStatement).compact

                    next_statement_ids = next_statement_ids.uniq - processed_ids
                end

                statements_mapper.map_statements all_statements
            end

            private

            attr_reader :statement_repository, :statements_mapper

            def load_by_ids(statement_ids)
                statement_repository.get_bulk(statement_ids)
            end

            def load_associated_statements(statement_ids)
                statement_repository.list_associated(statement_ids)
            end

            def load_by_identifiers(identifiers)
                statement_repository.list_matching_at_least_one_identifier(identifiers)
            end

            def single_loader(statement_ids, processed_ids: [])
                statement_ids = statement_ids.uniq - processed_ids

                # load by id
                statements = load_by_ids(statement_ids) + load_associated_statements(statement_ids)

                # load additional statements using identifiers
                identifiers = statements.map do |statement|
                    statement.identifiers.find do |identifier|
                        identifier.schemeName == "OpenOwnership Register"
                    end
                end.compact

                statements = statement_repository.list_matching_at_least_one_identifier(identifiers)

                statements.map { |statement| [statement.statementID, statement] }.to_h
            end
        end
    end
end
