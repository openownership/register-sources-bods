require 'register_bods_v2/types'

require 'register_bods_v2/structs/publisher'

module RegisterBodsV2
  class PublicationDetails < Dry::Struct
    attribute :publicationDate, Types::String.optional
    attribute :bodsVersion, Types::String.optional
    attribute :license, Types::String.optional
    attribute :publisher, Publisher
  end
end
