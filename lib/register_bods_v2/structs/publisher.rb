require 'register_bods_v2/types'

module RegisterBodsV2
  class Publisher < Dry::Struct
    attribute :name, Types::String.optional
    attribute :url, Types::String.optional
  end
end
