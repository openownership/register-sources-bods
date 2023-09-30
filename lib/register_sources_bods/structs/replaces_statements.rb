# frozen_string_literal: true

require 'register_sources_bods/types'

module RegisterSourcesBods
  class ReplacesStatements < Dry::Struct
    transform_keys(&:to_sym)

    attribute :value, Types::String.optional
  end
end
