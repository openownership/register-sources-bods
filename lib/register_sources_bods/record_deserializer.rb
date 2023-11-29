# frozen_string_literal: true

require 'json'
require 'register_common/utils/object'

require_relative 'structs/bods_statement'

module RegisterSourcesBods
  class RecordDeserializer
    def self.fix_parsed!(record)
      record['interests']&.each do |interest|
        v = interest.dig('share', 'exact')
        v.tr!(',', '.') if v.is_a?(String) && v.include?(',')
      end
    end

    def deserialize(record)
      parsed = JSON.parse(record)
      parsed2 = RegisterCommon::Utils::Object.compact_deep(parsed, prune: true)
      self.class.fix_parsed!(parsed2)
      BodsStatement[parsed2]
    end
  end
end
