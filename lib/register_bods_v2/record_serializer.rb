require 'json'

module RegisterBodsV2
  class RecordSerializer
    def serialize(record)
      print "\n\n", JSON.pretty_generate(record.to_h), "\n\n"
      record.to_h.to_json
    end
  end
end
