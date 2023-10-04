# frozen_string_literal: true

require_relative '../enums/unspecified_reasons'
require_relative '../types'
require_relative 'jurisdiction'
require_relative 'source'

module RegisterSourcesBods
  class PepStatusDetails < Dry::Struct
    transform_keys(&:to_sym)

    attribute? :reason,            Types::String
    attribute? :missingInfoReason, UnspecifiedReasons
    attribute? :jurisdiction,      Jurisdiction
    attribute? :startDate,         Types::String
    attribute? :endDate,           Types::String
    attribute? :source,            Source
  end
end
