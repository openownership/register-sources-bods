# frozen_string_literal: true

require_relative '../types'

module RegisterSourcesBods
  NameTypes = Types::String.enum(
    'individual',
    'translation',
    'transliteration',
    'former',
    'alternative',
    'birth'
  )
end
