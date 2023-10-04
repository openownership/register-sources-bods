# frozen_string_literal: true

require_relative '../enums/address_types'
require_relative '../types'

module RegisterSourcesBods
  class Address < Dry::Struct
    transform_keys(&:to_sym)

    attribute? :type,     AddressTypes
    attribute? :address,  Types::String
    attribute? :postCode, Types::String
    attribute? :country,  Types::String
  end
end
