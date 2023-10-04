# frozen_string_literal: true

require_relative '../enums/annotation_motivations'
require_relative '../types'

module RegisterSourcesBods
  class Annotation < Dry::Struct
    transform_keys(&:to_sym)

    attribute :statementPointerTarget, Types::String.optional
    attribute :creationDate,           Types::String.optional
    attribute :createdBy,              Types::String.optional # object, name, url
    attribute :motivation,             AnnotationMotivations
    attribute :description,            Types::String.optional
    attribute :transformedContent,     Types::String.optional
    attribute :url,                    Types::String.optional
  end
end
