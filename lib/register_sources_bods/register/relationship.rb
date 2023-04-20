require_relative 'provenance'

module RegisterSourcesBods
    module Register
        class Relationship
            def initialize(bods_statement)
                @bods_statement = bods_statement
                @provenance = Provenance.new(bods_statement)

                @source = nil
                @target = nil
            end

            attr_reader :provenance, :bods_statement

            attr_accessor :source, :target, :sourced_relationships

            def _id
                id
            end

            def ended_date
                return unless interests

                interests.map(&:endDate).compact.max
            end

            def id
                bods_statement.statementID
            end

            def interests
                return unless bods_statement.respond_to?(:interests)

                bods_statement.interests
            end

            def is_indirect
                false
            end

            def keys_for_uniq_grouping
                [source_id, target_id].compact.map(&:to_s) + interests.to_a.map(&:type).sort
            end

            def sample_date
                return unless interests

                interests.map(&:startDate).compact.min
            end

            def started_date
                return unless interests

                interests.map(&:startDate).compact.min
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
