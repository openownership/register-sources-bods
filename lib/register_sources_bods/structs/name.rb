# frozen_string_literal: true

require_relative '../enums/name_types'
require_relative '../types'

module RegisterSourcesBods
  class Name < Dry::Struct
    transform_keys(&:to_sym)

    attribute? :type,           NameTypes
    attribute? :fullName,       Types::String
    attribute? :familyName,     Types::String
    attribute? :givenName,      Types::String
    attribute? :patronymicName, Types::String
  end
end
