require 'register_bods_v2/types'

module RegisterBodsV2
  class Name < Dry::Struct
    attribute :type, Types::String.optional
    attribute :fullName, Types::String.optional
    attribute :familyName, Types::String.optional
    attribute :givenName, Types::String.optional
    attribute :patronymicName, Types::String.optional
  end
end
