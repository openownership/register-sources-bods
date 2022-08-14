require 'register_bods_v2/types'

module RegisterBodsV2
  InterestLevels = Types::String.enum(
    'direct',
    'indirect',
    'unknown'
  )
end
