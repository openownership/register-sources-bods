require 'register_bods_v2/types'
require 'register_bods_v2/enums/annotation_motivations'

module RegisterBodsV2
  class Annotation < Dry::Struct
    attribute :statementPointerTarget, Types::String.optional
    attribute :creationDate, Types::String.optional
    attribute :createdBy, Types::String.optional  # object, name, url
    attribute :motivation, AnnotationMotivations
    attribute :description, Types::String.optional
    attribute :transformedContent, Types::String.optional
    attribute :url, Types::String.optional
  end
end
