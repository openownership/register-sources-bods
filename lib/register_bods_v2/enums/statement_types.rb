require 'register_bods_v2/types'

module RegisterBodsV2
  StatementTypes = Types::String.enum(
    'personStatement',
    'entityStatement',
    'ownershipOrControlStatement'
  )
end
