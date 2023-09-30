# frozen_string_literal: true

require 'register_sources_bods/types'

module RegisterSourcesBods
  class Share < Dry::Struct
    transform_keys(&:to_sym)

    attribute? :exact, Types::Coercible::Float
    attribute? :maximum, Types::Coercible::Float
    attribute? :minimum, Types::Coercible::Float
    attribute? :exclusiveMinimum, Types::Params::Bool
    attribute? :exclusiveMaximum, Types::Params::Bool
  end
end
