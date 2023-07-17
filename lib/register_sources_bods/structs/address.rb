require 'register_sources_bods/types'
require 'register_sources_bods/enums/address_types'

module RegisterSourcesBods
  class Address < Dry::Struct
    transform_keys(&:to_sym)

    attribute? :type, AddressTypes
    attribute? :address, Types::String
    attribute? :postCode, Types::String
    attribute? :country, Types::String
  end
end
