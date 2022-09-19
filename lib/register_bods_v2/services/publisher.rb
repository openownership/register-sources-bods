require 'register_bods_v2/publishers/entity_statement'
require 'register_bods_v2/publishers/person_statement'
require 'register_bods_v2/publishers/ownership_or_control_statement'
require 'register_bods_v2/structs/bods_statement'

module RegisterBodsV2
  module Services
    class Publisher
      def initialize(
        entity_statement_publisher: nil,
        person_statement_publisher: nil,
        ownership_or_control_statement_publisher: nil
      )
        entity_statement_publisher ||= Publishers::EntityStatement.new
        person_statement_publisher ||= Publishers::PersonStatement.new
        ownership_or_control_statement_publisher ||= Publishers::OwnershipOrControlStatement.new        

        @publishers = {
          StatementTypes['personStatement'] => person_statement_publisher,
          StatementTypes['entityStatement'] => entity_statement_publisher,
          StatementTypes['ownershipOrControlStatement'] => ownership_or_control_statement_publisher,
        }
      end

      def publish(record)
        record = BodsStatement[record.to_h.compact]
        publishers[record.statementType].publish record
      rescue KeyError, Dry::Types::CoercionError
        raise UnknownRecordKindError
      end

      private

      attr_reader :publishers
    end
  end
end
