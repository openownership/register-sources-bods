module RegisterSourcesBods
    module Register
        class Provenance
            def initialize(bods_statement)
                @bods_statement = bods_statement
            end

            attr_reader :bods_statement

            def source_url
                bods_statement&.source&.url
            end

            def source_name
                bods_statement&.source&.description
            end

            def retrieved_at
                bods_statement&.source&.retrievedAt
            end

            def imported_at
                bods_statement&.source&.retrievedAt
            end
        end
    end
end
