require 'register_sources_bods/structs/person_statement'

module RegisterSourcesBods
  module Transformer
    class PersonStatement
      def self.call(bods_entity, **kwargs)
        new(bods_entity, **kwargs).call
      end

      def initialize(bods_entity)
        @bods_entity = bods_entity
      end

      def call
        RegisterSourcesBods::PersonStatement[bods_entity.to_h.merge({
          identifiers: (bods_entity.identifiers || []),
        }).compact]
      end

      private

      attr_reader :bods_entity
    end
  end
end
