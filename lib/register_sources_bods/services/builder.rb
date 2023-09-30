# frozen_string_literal: true

require 'register_sources_bods/constants/errors'
require 'register_sources_bods/builders/entity_statement'
require 'register_sources_bods/builders/person_statement'
require 'register_sources_bods/builders/ownership_or_control_statement'
require 'register_sources_bods/services/id_generator'
require 'register_sources_bods/enums/statement_types'

module RegisterSourcesBods
  module Services
    class Builder
      def initialize(
        entity_statement_builder: nil,
        person_statement_builder: nil,
        ownership_or_control_statement_builder: nil,
        id_generator: nil
      )
        id_generator ||= Services::IdGenerator.new
        entity_statement_builder ||= Builders::EntityStatement.new(id_generator)
        person_statement_builder ||= Builders::PersonStatement.new(id_generator)
        ownership_or_control_statement_builder ||= Builders::OwnershipOrControlStatement.new(id_generator)

        @builders = {
          StatementTypes['personStatement'] => person_statement_builder,
          StatementTypes['entityStatement'] => entity_statement_builder,
          StatementTypes['ownershipOrControlStatement'] => ownership_or_control_statement_builder
        }
      end

      def build(record, replaces_ids: [])
        builders.fetch(record.statementType).build(record, replaces_ids:)
      rescue KeyError
        raise Errors::UnknownRecordKindError
      end

      private

      attr_reader :builders
    end
  end
end
