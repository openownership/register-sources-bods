require 'register_bods_v2/types'

module RegisterBodsV2
  class Share < Dry::Struct
    transform_keys(&:to_sym)

    attribute? :exact, Types::Coercible::Float
    attribute? :maximum, Types::Coercible::Float
    attribute? :minimum, Types::Coercible::Float
    attribute? :exclusiveMinimum, Types::Params::Bool
    attribute? :exclusiveMaximum, Types::Params::Bool
  end
end
