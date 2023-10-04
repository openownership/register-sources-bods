# frozen_string_literal: true

require_relative '../enums/source_types'
require_relative '../types'
require_relative 'agent'

module RegisterSourcesBods
  class Source < Dry::Struct
    transform_keys(&:to_sym)

    attribute :type,        SourceTypes
    attribute :description, Types::String.optional
    attribute :url,         Types::String.optional
    attribute :retrievedAt, Types::String.optional
    attribute :assertedBy,  Agent.optional
  end
end
