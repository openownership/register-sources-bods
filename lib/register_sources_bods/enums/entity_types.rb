require 'register_sources_bods/types'

module RegisterSourcesBods
  EntityTypes = Types::String.enum(
    'registeredEntity',
    'legalEntity',
    'arrangement',
    'anonymousEntity',
    'unknownEntity',
  )
end
