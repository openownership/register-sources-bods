# frozen_string_literal: true

require 'json'
require 'register_common/utils/object'

require_relative 'structs/bods_statement'

module RegisterSourcesBods
  class RecordDeserializer
    def deserialize(record)
      parsed = JSON.parse(record)
      parsed2 = RegisterCommon::Utils::Object.compact_deep(parsed, prune: true)
      BodsStatement[parsed2]
    end
  end
end
