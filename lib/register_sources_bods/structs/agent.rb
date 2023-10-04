# frozen_string_literal: true

require_relative '../types'

module RegisterSourcesBods
  class Agent < Dry::Struct
    transform_keys(&:to_sym)

    attribute :name, Types::String.optional
    attribute :url,  Types::String.optional
  end
end
