require 'countries'
require 'iso8601'
require 'register_sources_bods/register/paginated_array'

module RegisterSourcesBods
    module Register
        class Entity
            def initialize(bods_statement)
                @bods_statement = bods_statement

                @master_entity = nil
                @merged_entities = Register::PaginatedArray.new([])
                @relationships_as_source = []
                @relationships_as_target = []
                @replaced_bods_statements = []

                @resolver_response = nil # TODO: remove resolver response
                @tmp = {}
            end

            attr_reader :bods_statement

            attr_accessor :replaced_bods_statements, :relationships_as_source, :relationships_as_target, :master_entity, :merged_entities, :resolver_response

            def all_bods_statements
                [bods_statement] + replaced_bods_statements
            end

            def [](k)
                @tmp[k]
            end

            def []=(k, v)
                @tmp[k] = v
            end

            def lang_code
                'gb' # TODO: implement
            end

            def address
                bods_statement.addresses&.first&.address
            end

            def addresses
                bods_statement.addresses
            end

            def company_number
                bods_statement.identifiers.find { |ident| ident.scheme == "GB-COH" }&.id
            end

            def company_number?
                company_number.present?
            end

            def company_type
                nil
            end

            def country
                country_code =
                    if bods_statement.statementType == RegisterSourcesBods::StatementTypes['personStatement']
                        # TODO: Multiple supported but just reading first
                        bods_statement.nationalities&.first&.code
                    else
                        bods_statement.incorporatedInJurisdiction&.code 
                    end

                return unless country_code

                ISO3166::Country[country_code]
            end

            def country_subdivision
                nil
            end

            def country_of_residence
                nil
            end

            def dissolution_date
                return unless bods_statement.respond_to?(:dissolutionDate)

                bods_statement.dissolutionDate
            end

            def date_of_birth
                dob
            end

            def dob
                return unless bods_statement.respond_to?(:birthDate)

                dob = bods_statement.birthDate

                return unless dob

                ISO8601::Date.new(dob)
            end

            def id
                ident = identifiers.find { |identifier| identifier.schemeName == "OpenOwnership Register" }

                ident ? ident.id.split('/').last : bods_statement.statementID
            end

            def identifiers
                bods_statement.identifiers
            end

            def incorporation_date
                return unless bods_statement.respond_to?(:foundingDate)

                bods_statement.foundingDate
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

                bods_statement.incorporatedInJurisdiction&.code
            end

            def jurisdiction_code?
                jurisdiction_code.present?
            end

            def name
                if natural_person?
                    bods_statement.names.first&.fullName
                  else
                    bods_statement.name
                  end
            end

            def natural_person?
                return false unless bods_statement

                bods_statement.statementType == RegisterSourcesBods::StatementTypes['personStatement']
            end

            def self_updated_at
                bods_statement&.publicationDetails&.publicationDate
            end

            def type
                bods_statement.statementType
            end

            def unknown_reason
                nil
            end

            def from_denmark_cvr_v2?
                bods_statement.identifiers.any? { |e| e.scheme == 'DK-CVR' }
            end

            def merged_entities_count
                merged_entities.count
            end

            def schema
                natural_person? ? person_schema : organisation_schema
              end
            
              def person_schema
                {
                  "@context" => "https://schema.org/",
                  "@type" => "Person",
                  "name": name,
                  "address" => address,
                  # "birthDate" => h.partial_date_format(dob),
                  # "url" => Rails.application.routes.url_helpers.entity_url(object),
                }.compact.to_json
              end
            
              def organisation_schema
                {
                  "@context" => "https://schema.org/",
                  "@type" => "Organization",
                  "name" => name,
                  "address" => address,
                  "foundingDate" => incorporation_date,
                  "dissolutionDate" => dissolution_date,
                  # "url" => Rails.application.routes.url_helpers.entity_url(object),
                }.compact.to_json
              end
        end
    end
end
