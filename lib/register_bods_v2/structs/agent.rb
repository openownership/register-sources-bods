require 'register_bods_v2/types'

module RegisterBodsV2
  class Agent < Dry::Struct
    transform_keys(&:to_sym)

    attribute :name, Types::String.optional
    attribute :url, Types::String.optional
  end
end
