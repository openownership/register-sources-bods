require 'register_bods_v2/types'
require 'register_bods_v2/enums/address_types'

module RegisterBodsV2
  class Address < Dry::Struct    
    transform_keys(&:to_sym)

    attribute :type, AddressTypes
    attribute :address, Types::String.optional
    attribute :postCode, Types::String.optional
    attribute :country, Types::String.optional
  end
end
