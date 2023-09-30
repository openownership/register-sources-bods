# frozen_string_literal: true

require 'register_sources_bods/types'

require 'register_sources_bods/structs/publisher'

module RegisterSourcesBods
  class PublicationDetails < Dry::Struct
    transform_keys(&:to_sym)

    attribute :publicationDate, Types::String.optional
    attribute :bodsVersion, Types::String.optional
    attribute :license, Types::String.optional
    attribute :publisher, Publisher
  end
end
