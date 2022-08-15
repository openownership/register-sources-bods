require 'register_bods_v2/types'

module RegisterBodsV2
  class Jurisdiction < Dry::Struct
    transform_keys(&:to_sym)

    attribute :name, Types::String.optional
    attribute :code, Types::String.optional
  end
end
