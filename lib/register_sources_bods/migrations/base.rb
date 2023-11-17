# frozen_string_literal: true

require_relative '../constants/identifiers'

module RegisterSourcesBods
  module Migrations
    class Base
      def log_doc(doc)
        identifier = doc['_source']['identifiers']&.select do |i|
          i['schemeName'] == REGISTER_SCHEME_NAME
        end&.first
        puts [
          doc['_index'],
          doc['_id'].ljust(20),
          (identifier ? identifier['id'] : '').ljust(30),
          doc['_source']['name']
        ].join(' ')
      end
    end
  end
end
