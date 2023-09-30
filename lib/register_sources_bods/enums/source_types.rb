# frozen_string_literal: true

require 'register_sources_bods/types'

module RegisterSourcesBods
  SourceTypes = Types::String.enum(
    'selfDeclaration',
    'officialRegister',
    'thirdParty',
    'primaryResearch',
    'verified'
  )
end
