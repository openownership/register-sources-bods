require 'register_bods_v2/types'

module RegisterBodsV2
  class Share < Dry::Struct
    transform_keys(&:to_sym)

    attribute :exact, Types::String.optional
    attribute :maximum, Types::String.optional
    attribute :minimum, Types::String.optional
    attribute :exclusiveMinimum, Types::String.optional
    attribute :exclusiveMaximum, Types::String.optional
  end
end
