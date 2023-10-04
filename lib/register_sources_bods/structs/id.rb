# frozen_string_literal: true

require_relative '../types'

module RegisterSourcesBods
  class Id < Dry::Struct
    transform_keys(&:to_sym)

    attribute :id, Types::String.optional
  end
end
