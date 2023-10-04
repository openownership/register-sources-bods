# frozen_string_literal: true

require_relative '../types'

module RegisterSourcesBods
  class Jurisdiction < Dry::Struct
    transform_keys(&:to_sym)

    attribute  :name, Types::String
    attribute? :code, Types::String
  end
end
