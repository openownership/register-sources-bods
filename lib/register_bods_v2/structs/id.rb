require 'register_bods_v2/types'

module RegisterBodsV2
  class Id < Dry::Struct
    transform_keys(&:to_sym)
 
    attribute :id, Types::String.optional
  end
end
