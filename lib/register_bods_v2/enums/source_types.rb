require 'register_bods_v2/types'

module RegisterBodsV2
  SourceTypes = Types::String.enum(
    'selfDeclaration',
    'officialRegister',
    'thirdParty',
    'primaryResearch',
    'verified'
  )
end
