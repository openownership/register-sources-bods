module RegisterSourcesBods
    module Register
        class StatementLoader
            def initialize(statement_repository:)
                @statement_repository = statement_repository
            end

            def load_associated_statements(statement_ids)

            end

            private

            attr_reader :statement_repository
        end
    end
end
