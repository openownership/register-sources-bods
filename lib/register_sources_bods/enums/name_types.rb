# frozen_string_literal: true

require 'register_sources_bods/types'

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
