require 'register_bods_v2/types'

module RegisterBodsV2
  class Id < Dry::Struct
    attribute :id, Types::String.optional
  end
end
