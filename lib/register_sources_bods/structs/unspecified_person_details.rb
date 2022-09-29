require 'register_sources_bods/types'
require 'register_sources_bods/enums/unspecified_reasons'

module RegisterSourcesBods
  class UnspecifiedPersonDetails < Dry::Struct
    transform_keys(&:to_sym)

    attribute :reason, UnspecifiedReasons
    attribute? :description, Types::String.optional
  end
end
