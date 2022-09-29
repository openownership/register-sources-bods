require 'register_sources_bods/types'

require 'register_sources_bods/structs/jurisdiction'
require 'register_sources_bods/structs/source'
require 'register_sources_bods/enums/unspecified_reasons'

module RegisterSourcesBods
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
