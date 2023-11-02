# frozen_string_literal: true

require 'json'
require 'register_sources_bods/structs/bods_statement'

module RegisterSourcesBods
  class RecordDeserializer
    def deserialize(record)
      parsed = JSON.parse(record)

      BodsStatement[parsed]
    end
  end
end
