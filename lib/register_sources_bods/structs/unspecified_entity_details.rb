# frozen_string_literal: true

require_relative '../enums/unspecified_reasons'
require_relative '../types'

module RegisterSourcesBods
  class UnspecifiedEntityDetails < Dry::Struct
    transform_keys(&:to_sym)

    attribute  :reason,      UnspecifiedReasons
    attribute? :description, Types::String.optional
  end
end
