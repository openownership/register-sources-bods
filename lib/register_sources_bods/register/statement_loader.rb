module RegisterSourcesBods
    module Register
        class StatementLoader
            def initialize(statement_repository:, statements_mapper:)
                @statement_repository = statement_repository
                @statements_mapper = statements_mapper
            end

            def load_associated_statements(statement_ids)

            end

            private

            attr_reader :statement_repository, :statements_mapper
        end
    end
end
