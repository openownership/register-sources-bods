require 'register_bods_v2/types'
require 'register_bods_v2/enums/unspecified_reasons'

module RegisterBodsV2
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
