require 'register_sources_bods/types'

require 'register_sources_bods/enums/source_types'
require 'register_sources_bods/structs/agent'

module RegisterSourcesBods
  class Source < Dry::Struct
    transform_keys(&:to_sym)

    attribute :type, SourceTypes
    attribute :description, Types::String.optional
    attribute :url, Types::String.optional
    attribute :retrievedAt, Types::String.optional
    attribute :assertedBy, Agent.optional
  end
end
