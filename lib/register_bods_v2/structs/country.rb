require 'register_bods_v2/types'

module RegisterBodsV2
  class Country < Dry::Struct
    attribute :name, Types::String.optional
    attribute :code, Types::String.optional
  end
end
