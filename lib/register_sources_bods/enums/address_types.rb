# frozen_string_literal: true

require_relative '../types'

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
