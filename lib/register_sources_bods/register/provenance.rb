module RegisterSourcesBods
    module Register
        class Provenance
            def initialize(statement)
                @statement = statement
            end

            def source_url

            end

            def source_name

            end

            def retrieved_at

            end

            def imported_at

            end

            private

            attr_reader :statement
        end
    end
end
