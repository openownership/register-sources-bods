require 'register_bods_v2/types'

module RegisterBodsV2
  class Identifier < Dry::Struct
    transform_keys(&:to_sym)

    attribute? :id, Types::String
    attribute? :scheme, Types::String
    attribute? :schemeName, Types::String
    attribute? :uri, Types::String
  end
end
