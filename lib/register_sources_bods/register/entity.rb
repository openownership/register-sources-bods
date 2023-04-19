require 'countries'
require 'iso8601'

module RegisterSourcesBods
    module Register
        class Entity
            def initialize(statement)
                @statement = statement

                @master_entity = nil
                @merged_entities = []
                @relationships_as_source = []
                @relationships_as_target = []

                @resolver_response = nil
            end

            attr_reader :statement

            attr_accessor :relationships_as_source, :relationships_as_target, :master_entity, :merged_entities, :resolver_response

            def address
                statement.addresses&.first&.address
            end

            def company_number
                statement.identifiers.find { |ident| ident.scheme == "GB-COH" }&.id
            end

            def company_number?
                company_number.present?
            end

            def company_type
            end

            def country
                country_code =
                    if statement.statementType == RegisterSourcesBods::StatementTypes['personStatement']
                        # TODO: Multiple supported but just reading first
                        statement&.nationalities&.first&.code
                    else
                        statement&.incorporatedInJurisdiction&.code 
                    end

                return unless country_code

                ISO3166::Country[country_code]
            end

            def country_subdivision
                nil
            end

            def country_of_residence
            end

            def dissolution_date
                return unless statement.respond_to?(:dissolutionDate)

                statement.dissolutionDate
            end

            def dob
                return unless statement.respond_to?(:birthDate)

                dob = statement.birthDate

                return unless dob

                ISO8601::Date.new(dob)
            end

            def id
                
            end

            def identifiers
                statement.identifiers
            end

            def incorporation_date
                return unless statement.respond_to?(:foundingDate)

                statement.foundingDate
            end

            def incorporation_date?
                incorporation_date.present?
            end

            def jurisdiction_code
                return unless resolver_response

                jurisdiction_code = resolver_response.jurisdiction_code
                return unless jurisdiction_code
            
                code, = jurisdiction_code.split('_')
                country = ISO3166::Country[code]
                return nil if country.blank?

                RegisterSourcesBods::Jurisdiction.new(name: country.name, code: country.alpha2)

                statement&.incorporatedInJurisdiction&.code
            end

            def jurisdiction_code?
                jurisdiction_code.present?
            end

            def name
            end

            def natural_person?
                return false unless statement

                statement.statementType == RegisterSourcesBods::StatementTypes['personStatement']
            end

            def self_updated_at
            end

            def type
            end

            def unknown_reason
            end

            def from_denmark_cvr_v2?
                statement.identifiers.any? { |e| e.scheme == 'DK-CVR' }
            end

            def merged_entities_count
                merged_entities.count
            end
        end
    end
end
