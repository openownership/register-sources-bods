require 'register_bods_v2/types'
require 'register_bods_v2/enums/unspecified_reasons'

module RegisterBodsV2
  class UnspecifiedPersonDetails < Dry::Struct
    transform_keys(&:to_sym)

    attribute :reason, UnspecifiedReasons
    attribute? :description, Types::String.optional
  end
end
