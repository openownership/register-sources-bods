require 'register_bods_v2/types'

require 'register_bods_v2/structs/jurisdiction'
require 'register_bods_v2/structs/source'
require 'register_bods_v2/enums/unspecified_reasons'

module RegisterBodsV2
  class PepStatusDetails < Dry::Struct
    transform_keys(&:to_sym)

    attribute? :reason, Types::String
    attribute? :missingInfoReason, UnspecifiedReasons
    attribute? :jurisdiction, Jurisdiction
    attribute? :startDate, Types::String
    attribute? :endDate, Types::String
    attribute? :source, Source
  end
end
