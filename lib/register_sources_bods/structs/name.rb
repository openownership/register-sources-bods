require 'register_sources_bods/types'
require 'register_sources_bods/enums/name_types'

module RegisterSourcesBods
  class Name < Dry::Struct
    transform_keys(&:to_sym)

    attribute? :type, NameTypes
    attribute? :fullName, Types::String
    attribute? :familyName, Types::String
    attribute? :givenName, Types::String
    attribute? :patronymicName, Types::String
  end
end
