require 'register_bods_v2/types'

module RegisterBodsV2
  class Subject < Dry::Struct
    attribute :describedByEntityStatement, Types::String.optional
  end
end
