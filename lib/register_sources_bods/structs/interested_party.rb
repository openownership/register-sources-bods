# frozen_string_literal: true

require 'register_sources_bods/types'
require 'register_sources_bods/enums/unspecified_reasons'

module RegisterSourcesBods
  class InterestedParty < Dry::Struct
    transform_keys(&:to_sym)

    attribute? :describedByEntityStatement, Types::String
    attribute? :describedByPersonStatement, Types::String
    attribute? :unspecified do
      attribute :reason, UnspecifiedReasons
      attribute? :description, Types::String.optional
    end
  end
end
