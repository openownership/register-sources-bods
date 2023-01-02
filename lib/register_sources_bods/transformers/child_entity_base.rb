require 'ostruct'

require 'register_sources_bods/enums/entity_types'
require 'register_sources_bods/enums/statement_types'
require 'register_sources_bods/structs/address'
require 'register_sources_bods/structs/entity_statement'
require 'register_sources_bods/structs/identifier'
require 'register_sources_bods/structs/jurisdiction'

require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/object/try'
require 'active_support/core_ext/time'
require 'active_support/core_ext/string/conversions'

module RegisterSourcesBods
    module Transformers
        class ChildEntityResolver
            OPEN_CORPORATES_SCHEME_NAME = 'OpenCorporates'

            def initialize(child_entity, resolver_response, logger: nil)
                @child_entity = child_entity
                @resolver_response = resolver_response
                @logger = logger
            end

            def call
                return child_entity unless resolver_response

                RegisterSourcesBods::EntityStatement[
                    child_entity.to_h.merge(
                        incorporatedInJurisdiction: incorporated_in_jurisdiction,
                        identifiers: identifiers,
                        foundingDate: founding_date,
                        dissolutionDate: dissolution_date
                    ).compact
                ]
            end

            private

            attr_reader :child_entity, :resolver_response, :logger

            def identifiers
                # if resolved and no open_corporates identifier, add it to existing, else return existing
            end

            def open_corporates_identifier
                return unless resolver_response && resolver_response.resolved

                jurisdiction = resolver_response.jurisdiction_code
                company_number = resolver_response.company_number
                oc_url = "https://opencorporates.com/companies/#{jurisdiction}/#{company_number}"

                RegisterSourcesBods::Identifier[{
                    id: oc_url,
                    schemeName: OPEN_CORPORATES_SCHEME_NAME,
                    uri: oc_url
                }]
            end

            def incorporated_in_jurisdiction
                jurisdiction_code = resolver_response.jurisdiction_code
                return unless jurisdiction_code
            
                code, = jurisdiction_code.split('_')
                country = ISO3166::Country[code]
                return nil if country.blank?

                RegisterSourcesBods::Jurisdiction.new(name: country.name, code: country.alpha2)
            end

            def founding_date
                return unless resolver_response.company

                date = resolver_response.company.incorporation_date&.to_date
                return unless date

                date.try(:iso8601)
            rescue Date::Error
                return unless logger

                logger.warn "Entity has invalid incorporation_date: #{date}"
                nil
            end

            def dissolution_date
                return unless resolver_response.company

                date = resolver_response.company.dissolution_date&.to_date
                return unless date

                date.try(:iso8601)
            rescue Date::Error
                return unless logger

                logger.warn "Entity has invalid dissolution_date: #{date}"
                nil
            end
        end
    end
end
