require 'register_bods_v2/types'

module RegisterBodsV2
  AddressTypes = Types::String.enum(
    'placeOfBirth',
    'residence',
    'registered',
    'service',
    'alternative',
    'business'
  )
end
