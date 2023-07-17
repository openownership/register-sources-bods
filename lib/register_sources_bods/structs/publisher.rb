require 'register_sources_bods/types'

module RegisterSourcesBods
  class Publisher < Dry::Struct
    transform_keys(&:to_sym)

    attribute :name, Types::String.optional
    attribute :url, Types::String.optional
  end
end
