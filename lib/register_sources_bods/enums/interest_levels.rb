require 'register_sources_bods/types'

module RegisterSourcesBods
  InterestLevels = Types::String.enum(
    'direct',
    'indirect',
    'unknown',
  )
end
