# frozen_string_literal: true

require_relative '../types'

module RegisterSourcesBods
  class Identifier < Dry::Struct
    transform_keys(&:to_sym)

    attribute? :id,         Types::String
    attribute? :scheme,     Types::String
    attribute? :schemeName, Types::String
    attribute? :uri,        Types::String
  end
end
