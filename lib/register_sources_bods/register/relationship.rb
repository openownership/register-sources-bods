require_relative 'provenance'

module RegisterSourcesBods
    module Register
        class Relationship
            def initialize(statement)
                @statement = statement
                @provenance = Provenance.new(statement)
            end

            attr_reader 

            def _id

            end

            def ended_date

            end

            def id
            
            end

            def interests

            end

            def is_indirect

            end

            def keys_for_uniq_grouping

            end

            def sample_date

            end
  
            def source_id

            end
            
            def sourced_relationships

            end

            def started_date

            end

            def source

            end

            def target

            end

            def target_id

            end

            def type

            end
        end
    end
end
