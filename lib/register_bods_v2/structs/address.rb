require 'register_bods_v2/types'
require 'register_bods_v2/enums/address_types'

module RegisterBodsV2
  class Address < Dry::Struct    
    transform_keys(&:to_sym)

    attribute? :type, AddressTypes
    attribute? :address, Types::String
    attribute? :postCode, Types::String
    attribute? :country, Types::String
  end
end
