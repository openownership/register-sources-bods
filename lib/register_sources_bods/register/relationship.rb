require_relative 'provenance'

module RegisterSourcesBods
    module Register
        class Relationship
            def initialize(statement)
                @statement = statement
                @provenance = Provenance.new(statement)

                @source = nil
                @target = nil
            end

            attr_reader :provenance

            attr_accessor :source, :target, :sourced_relationships

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

            def started_date

            end

            def type

            end

            # ASSOCIATIONS

            def source_id
                source&.id
            end

            def target_id
                target&.id
            end
        end
    end
end
