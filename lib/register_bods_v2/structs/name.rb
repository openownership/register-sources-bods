require 'register_bods_v2/types'
require 'register_bods_v2/enums/name_types'

module RegisterBodsV2
  class Name < Dry::Struct
    transform_keys(&:to_sym)

    attribute? :type, NameTypes
    attribute? :fullName, Types::String
    attribute? :familyName, Types::String
    attribute? :givenName, Types::String
    attribute? :patronymicName, Types::String
  end
end
