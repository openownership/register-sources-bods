require 'register_sources_bods/types'
require 'register_sources_bods/enums/statement_types'
require 'register_sources_bods/structs/entity_statement'
require 'register_sources_bods/structs/ownership_or_control_statement'
require 'register_sources_bods/structs/person_statement'

module RegisterSourcesBods
  UnknownRecordKindError = Class.new(StandardError)

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
      raise UnknownRecordKindError
    end
  end
end
