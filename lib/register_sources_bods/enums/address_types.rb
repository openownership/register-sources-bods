# frozen_string_literal: true

require 'register_sources_bods/types'

module RegisterSourcesBods
  AddressTypes = Types::String.enum(
    'placeOfBirth',
    'residence',
    'registered',
    'service',
    'alternative',
    'business'
  )
end
