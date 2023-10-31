require 'uri'
require 'xxhash'

require 'register_sources_bods/enums/entity_types'
require 'register_sources_bods/enums/statement_types'
require 'register_sources_bods/structs/address'
require 'register_sources_bods/structs/entity_statement'
require 'register_sources_bods/structs/jurisdiction'
require 'register_sources_bods/constants/publisher'
require 'register_sources_bods/structs/publication_details'
require 'register_sources_bods/structs/source'
require 'register_sources_bods/mappers/resolver_mappings'

require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/object/try'
require 'active_support/core_ext/time'
require 'active_support/core_ext/string/conversions'

require 'register_sources_oc/structs/resolver_request'

module RegisterSourcesBods
  module Transformer
    class EntityStatement
      include RegisterSourcesBods::Mappers::ResolverMappings

      def self.call(bods_entity, **kwargs)
        new(bods_entity, **kwargs).call
      end

      def initialize(bods_entity, entity_resolver: nil)
        @bods_entity = bods_entity
        @entity_resolver = entity_resolver
      end

      def call
        RegisterSourcesBods::EntityStatement[{
          statementType: statement_type,
          statementDate: nil,
          isComponent: false,
          entityType: entity_type,
          name:,
          incorporatedInJurisdiction: incorporated_in_jurisdiction,
          identifiers:,
          foundingDate: founding_date,
          dissolutionDate: dissolution_date,
          addresses:,
          source:,
        }.compact]
      end

      private

      attr_reader :bods_entity, :entity_resolver

      def resolver_response
        return @resolver_response if @resolver_response

        jurisdiction_code = bods_entity.incorporatedInJurisdiction&.code

        return unless jurisdiction_code

        @resolver_response = entity_resolver.resolve(
          RegisterSourcesOc::ResolverRequest[{
            jurisdiction_code:,
            name:,
          }.compact],
        )
      end

      def statement_type
        bods_entity.statementType
      end

      def entity_type
        bods_entity.entityType
      end

      def identifiers
        (bods_entity.identifiers + [open_corporates_identifier, lei_identifier].compact).uniq
      end

      def name
        bods_entity.name
      end

      def addresses
        bods_entity.addresses
      end

      def incorporated_in_jurisdiction
        bods_entity.incorporatedInJurisdiction
      end

      def founding_date
        bods_entity.foundingDate || super
      end

      def dissolution_date
        bods_entity.dissolutionDate || super
      end

      def source
        bods_entity.source
      end
    end
  end
end
