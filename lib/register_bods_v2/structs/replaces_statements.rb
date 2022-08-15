require 'register_bods_v2/types'

module RegisterBodsV2
  class ReplacesStatements < Dry::Struct
    transform_keys(&:to_sym)

    attribute :value, Types::String.optional
  end
end
