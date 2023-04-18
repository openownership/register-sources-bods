module RegisterSourcesBods
    module Register
        class Statement
            def initialize(bods_statement)
                @bods_statement = bods_statement

                @entity = nil
            end

            attr_reader :bods_statement

            attr_accessor :entity

            def _id

            end

            def type

            end

            def date

            end

            def ended_date

            end

            # ASSOCIATIONS

            def entity_id
                entity&.id
            end
        end
    end
end
