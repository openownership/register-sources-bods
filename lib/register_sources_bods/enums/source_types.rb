# frozen_string_literal: true

require_relative '../types'

module RegisterSourcesBods
  SourceTypes = Types::String.enum(
    'selfDeclaration',
    'officialRegister',
    'thirdParty',
    'primaryResearch',
    'verified'
  )
end
