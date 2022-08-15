require 'register_bods_v2/types'
require 'register_bods_v2/enums/statement_types'
require 'register_bods_v2/structs/entity_statement'
require 'register_bods_v2/structs/ownership_or_control_statement'
require 'register_bods_v2/structs/person_statement'

module RegisterBodsV2
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
