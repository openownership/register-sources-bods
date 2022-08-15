require 'register_bods_v2/types'

require 'register_bods_v2/structs/source'
require 'register_bods_v2/enums/unspecified_reasons'

module RegisterBodsV2
  class PepStatusDetails < Dry::Struct
    attribute :reason, Types::String.optional
    attribute :missingInfoReason, UnspecifiedReasons
    attribute :jurisdiction, Types::String.optional
    attribute :startDate, Types::String.optional
    attribute :endDate, Types::String.optional
    attribute :source, Source
  end
end
