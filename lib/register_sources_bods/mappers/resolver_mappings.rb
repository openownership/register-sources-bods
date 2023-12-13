# frozen_string_literal: true

require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/object/try'
require 'active_support/core_ext/string/conversions'
require 'active_support/core_ext/time'

require_relative '../constants/identifiers'
require_relative '../enums/entity_types'
require_relative '../enums/statement_types'
require_relative '../structs/address'
require_relative '../structs/entity_statement'
require_relative '../structs/identifier'
require_relative '../structs/jurisdiction'

module RegisterSourcesBods
  module Mappers
    module ResolverMappings
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
          scheme: IDENTIFIER_SCHEME_LEI,
          schemeName: IDENTIFIER_NAME_LEI,
          uri:
        }]
      end

      def identifier_open_corporates_from_company(jurisdiction_code, company_number)
        uri = "https://opencorporates.com/companies/#{jurisdiction_code.downcase}/#{company_number.upcase}"
        RegisterSourcesBods::Identifier[{
          id: uri,
          schemeName: IDENTIFIER_NAME_OC,
          uri:
        }]
      end

      def name
        return unless resolver_response&.company

        resolver_response.company.name
      end

      def alternate_names
        return unless resolver_response&.resolved && resolver_response&.alt_names

        resolver_response.alt_names.map(&:name)
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

      def remap_identifier_open_corporates(identifier)
        parts = identifier.id.split('/')
        identifier_open_corporates_from_company(parts[-2], parts[-1])
      end

      private

      attr_reader :resolver_response
    end
  end
end
