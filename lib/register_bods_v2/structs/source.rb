require 'register_bods_v2/types'

require 'register_bods_v2/enums/source_types'
require 'register_bods_v2/structs/agent'

module RegisterBodsV2
  class Source < Dry::Struct
    transform_keys(&:to_sym)

    attribute :type, SourceTypes
    attribute :description, Types::String.optional
    attribute :url, Types::String.optional
    attribute :retrievedAt, Types::String.optional
    attribute :assertedBy, Agent.optional
  end
end
