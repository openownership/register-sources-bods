# frozen_string_literal: true

require_relative '../constants/errors'
require_relative '../enums/statement_types'
require_relative '../types'
require_relative 'entity_statement'
require_relative 'ownership_or_control_statement'
require_relative 'person_statement'

module RegisterSourcesBods
  BodsStatement = Types::Nominal::Any.constructor do |value|
    next value unless value.is_a? Hash

    case (value['statementType'] || value[:statementType])
    when StatementTypes['personStatement']
      PersonStatement.new(**value)
    when StatementTypes['entityStatement']
      EntityStatement.new(**value)
    when StatementTypes['ownershipOrControlStatement']
      OwnershipOrControlStatement.new(**value)
    else
      raise Errors::UnknownRecordKindError
    end
  end
end
