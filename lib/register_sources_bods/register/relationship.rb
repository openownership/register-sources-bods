require_relative 'provenance'

module RegisterSourcesBods
    module Register
        class Relationship
            def initialize(bods_statement)
                @bods_statement = bods_statement
                @provenance = Provenance.new(bods_statement)

                @source = nil
                @target = nil
                @tmp = {}
            end

            attr_reader :provenance, :bods_statement

            attr_accessor :source, :target, :sourced_relationships

            def all_bods_statements
                [bods_statement]
            end

            def [](k)
                @tmp[k]
            end

            def []=(k, v)
                @tmp[k] = v
            end

            def _id
                id
            end

            def ended_date
                return unless interests

                res = interests.map(&:endDate).compact.max

                res && ISO8601::Date.new(res)
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

                res = interests.map(&:startDate).compact.min

                res && ISO8601::Date.new(res)
            end

            def started_date
                return unless interests

                res = interests.map(&:startDate).compact.min

                res && ISO8601::Date.new(res)
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
