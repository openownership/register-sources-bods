# frozen_string_literal: true

require 'active_support/core_ext/object/blank'
require 'countries'
require 'iso8601'
require 'register_common/utils/paginated_array'

require_relative '../constants/identifiers'

module RegisterSourcesBods
  module Register
    class Entity
      SCHEME_DK  = 'DK-CVR'
      SCHEME_PSC = 'GB-COH'
      SCHEME_SK  = 'SK-ORSR'

      def initialize(bods_statement)
        @bods_statement = bods_statement

        @master_entity = nil
        @merged_entities = RegisterCommon::Utils::PaginatedArray.new([])
        @relationships_as_source = []
        @relationships_as_target = []
        @replaced_bods_statements = []

        @tmp = {}
      end

      attr_reader :bods_statement

      attr_accessor :replaced_bods_statements, :relationships_as_source,
                    :relationships_as_target, :master_entity, :merged_entities

      def all_bods_statements
        [bods_statement] + replaced_bods_statements
      end

      def [](key)
        @tmp[key]
      end

      def []=(key, val)
        @tmp[key] = val
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
        bods_statement.identifiers.find do |ident|
          [SCHEME_PSC, SCHEME_DK, SCHEME_SK].include? ident.scheme
        end&.id
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
        country_code = bods_statement.addresses&.first&.country

        return unless country_code

        ISO3166::Country[country_code]
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

        return unless dob.presence

        ISO8601::Date.new(dob)
      end

      def id
        ident = identifiers.find do |identifier|
          identifier.schemeName == IDENTIFIER_NAME_REG
        end

        ident ? ident.id.split('/').last : bods_statement.statementID
      end

      def identifiers
        bods_statement.identifiers
      end

      def identifiers_lei
        identifiers.select { |i| i.scheme == IDENTIFIER_SCHEME_LEI }
      end

      def incorporation_date
        return unless bods_statement.respond_to?(:foundingDate)

        bods_statement.foundingDate
      end

      def incorporation_date?
        incorporation_date.present?
      end

      def unknown?
        bods_statement.statementID.split('-').last == 'unknown'
      end

      def jurisdiction_code
        return unless bods_statement.respond_to?(:incorporatedInJurisdiction)

        bods_statement&.incorporatedInJurisdiction&.code
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

      def alternate_names
        bods_statement.alternateNames&.sort || []
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
        unknown? ? 'We have no data to tell us who this person or people might be.' : nil
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
          '@context' => 'https://schema.org/',
          '@type' => 'Person',
          name:,
          'address' => address
        }.compact.to_json
      end

      def organisation_schema
        {
          '@context' => 'https://schema.org/',
          '@type' => 'Organization',
          'name' => name,
          'address' => address,
          'foundingDate' => incorporation_date,
          'dissolutionDate' => dissolution_date
        }.compact.to_json
      end
    end
  end
end
