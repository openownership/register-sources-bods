# frozen_string_literal: true

require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/object/try'
require 'active_support/core_ext/string/conversions'
require 'active_support/core_ext/time'
require 'register_sources_oc/structs/resolver_request'
require 'uri'
require 'xxhash'

require_relative '../constants/publisher'
require_relative '../enums/entity_types'
require_relative '../enums/statement_types'
require_relative '../mappers/resolver_mappings'
require_relative '../structs/address'
require_relative '../structs/entity_statement'
require_relative '../structs/jurisdiction'
require_relative '../structs/publication_details'
require_relative '../structs/source'

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
        RegisterSourcesBods::EntityStatement[bods_entity.to_h.merge({
                                                                      identifiers:,
                                                                      foundingDate: founding_date,
                                                                      dissolutionDate: dissolution_date
                                                                    }).compact]
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
            name: bods_entity.name
          }.compact]
        )
      end

      def identifiers
        (bods_entity.identifiers.to_a + [open_corporates_identifier, lei_identifier].compact).uniq
      end

      def founding_date
        bods_entity.foundingDate || super
      end

      def dissolution_date
        bods_entity.dissolutionDate || super
      end
    end
  end
end
