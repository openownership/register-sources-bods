require 'register_bods_v2/types'

module RegisterBodsV2
  class Identifier < Dry::Struct
    transform_keys(&:to_sym)

    attribute :id, Types::String.optional
    attribute :scheme, Types::String.optional
    attribute :schemeName, Types::String.optional
    attribute :uri, Types::String.optional
  end
end
