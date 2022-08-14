require 'register_bods_v2/types'

module RegisterBodsV2
  NameTypes = Types::String.enum(
    'individual',
    'translation',
    'transliteration',
    'former',
    'alternative',
    'birth'
  )
end
