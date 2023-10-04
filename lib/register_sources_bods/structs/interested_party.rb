# frozen_string_literal: true

require_relative '../enums/unspecified_reasons'
require_relative '../types'

module RegisterSourcesBods
  class InterestedParty < Dry::Struct
    transform_keys(&:to_sym)

    attribute? :describedByEntityStatement, Types::String
    attribute? :describedByPersonStatement, Types::String
    attribute? :unspecified do
      attribute  :reason,      UnspecifiedReasons
      attribute? :description, Types::String.optional
    end
  end
end
