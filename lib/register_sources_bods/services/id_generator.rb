require 'register_sources_bods/constants/errors'
require 'register_sources_bods/id_generators/entity_statement'
require 'register_sources_bods/id_generators/person_statement'
require 'register_sources_bods/id_generators/ownership_or_control_statement'
require 'register_sources_bods/enums/statement_types'

module RegisterSourcesBods
  module Services
    class IdGenerator
      def initialize(
        entity_statement_id_generator: nil,
        person_statement_id_generator: nil,
        ownership_or_control_statement_id_generator: nil
      )
        entity_statement_id_generator ||= IdGenerators::EntityStatement.new
        person_statement_id_generator ||= IdGenerators::PersonStatement.new
        ownership_or_control_statement_id_generator ||= IdGenerators::OwnershipOrControlStatement.new

        @id_generators = {
          StatementTypes['personStatement'] => person_statement_id_generator,
          StatementTypes['entityStatement'] => entity_statement_id_generator,
          StatementTypes['ownershipOrControlStatement'] => ownership_or_control_statement_id_generator,
        }
      end

      def generate_id(record)
        id_generators.fetch(record.statementType).generate_id record
      rescue KeyError
        raise Errors::UnknownRecordKindError
      end

      private

      attr_reader :id_generators
    end
  end
end
