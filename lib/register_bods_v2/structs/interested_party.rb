require 'register_bods_v2/types'

module RegisterBodsV2
  class InterestedParty < Dry::Struct
    transform_keys(&:to_sym)

    attribute :describedByEntityStatement, Types::String.optional
    attribute :describedByPersonStatement, Types::String.optional
    attribute :unspecified, Types::String.optional # object, reason, description
  end
end
