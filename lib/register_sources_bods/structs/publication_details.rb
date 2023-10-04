# frozen_string_literal: true

require_relative '../types'
require_relative 'publisher'

module RegisterSourcesBods
  class PublicationDetails < Dry::Struct
    transform_keys(&:to_sym)

    attribute :publicationDate, Types::String.optional
    attribute :bodsVersion,     Types::String.optional
    attribute :license,         Types::String.optional
    attribute :publisher,       Publisher
  end
end
