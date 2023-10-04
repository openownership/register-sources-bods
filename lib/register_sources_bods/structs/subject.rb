# frozen_string_literal: true

require_relative '../types'

module RegisterSourcesBods
  class Subject < Dry::Struct
    transform_keys(&:to_sym)

    attribute :describedByEntityStatement, Types::String.optional
  end
end
