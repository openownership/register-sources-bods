require 'register_bods_v2/types'

module RegisterBodsV2
  PersonTypes = Types::String.enum(
    'knownPerson',
    'anonymousPerson',
    'unknownPerson'
  )
end
