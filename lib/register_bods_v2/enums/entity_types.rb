require 'register_bods_v2/types'

module RegisterBodsV2
  EntityTypes = Types::String.enum(
    'registeredEntity',
    'legalEntity',
    'arrangement',
    'anonymousEntity',
    'unknownEntity'
  )
end
