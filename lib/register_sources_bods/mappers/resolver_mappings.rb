# frozen_string_literal: true

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
  module Mappers
    module ResolverMappings
      LEI_SCHEME                  = 'XI-LEI'
      LEI_SCHEME_NAME             = 'Global Legal Entity Identifier Index'
      OPEN_CORPORATES_SCHEME_NAME = 'OpenCorporates'

      def addresses
        return [] unless resolver_response&.company

        address = resolver_response.company.registered_address_in_full.presence.try(:gsub, "\n", ', ')
        return [] if address.blank?

        country_code = incorporated_in_jurisdiction&.code

        [
          RegisterSourcesBods::Address[{
            type: RegisterSourcesBods::AddressTypes['registered'],
            address:,
            country: country_code
          }.compact]
        ]
      end

      def identifier_lei_from_add_id(add_id)
        uri = "https://search.gleif.org/#/record/#{add_id.uid}"
        RegisterSourcesBods::Identifier[{
          id: add_id.uid,
          scheme: LEI_SCHEME,
          schemeName: LEI_SCHEME_NAME,
          uri:
        }]
      end

      def identifier_open_corporates_from_company(jurisdiction_code, company_number)
        uri = "https://opencorporates.com/companies/#{jurisdiction_code}/#{company_number}"
        RegisterSourcesBods::Identifier[{
          id: uri,
          schemeName: OPEN_CORPORATES_SCHEME_NAME,
          uri:
        }]
      end

      def name
        return unless resolver_response&.company

        resolver_response.company.name
      end

      def lei_identifier
        return unless resolver_response&.resolved && resolver_response&.add_ids

        add_id = resolver_response.add_ids.find { |e| e.identifier_system_code == 'lei' }
        return unless add_id

        identifier_lei_from_add_id(add_id)
      end

      def open_corporates_identifier
        return unless resolver_response&.resolved

        identifier_open_corporates_from_company(resolver_response.jurisdiction_code, resolver_response.company_number)
      end

      def incorporated_in_jurisdiction
        return unless resolver_response

        jurisdiction_code = resolver_response.jurisdiction_code
        return unless jurisdiction_code

        code, = jurisdiction_code.split('_')
        country = ISO3166::Country[code]
        return nil if country.blank?

        RegisterSourcesBods::Jurisdiction.new(name: country.name, code: country.alpha2)
      end

      def founding_date
        return unless resolver_response&.company

        date = resolver_response.company.incorporation_date&.to_date

        return unless date

        date.try(:iso8601)
      rescue Date::Error
        LOGGER.warn "Entity has invalid incorporation_date: #{date}"
        nil
      end

      def dissolution_date
        return unless resolver_response&.company

        date = resolver_response.company.dissolution_date&.to_date

        return unless date

        date.try(:iso8601)
      rescue Date::Error
        LOGGER.warn "Entity has invalid dissolution_date: #{date}"
        nil
      end

      private

      attr_reader :resolver_response
    end
  end
end
