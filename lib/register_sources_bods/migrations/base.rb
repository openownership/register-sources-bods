# frozen_string_literal: true

require_relative '../constants/identifiers'

module RegisterSourcesBods
  module Migrations
    class Base
      BUFFER_SIZE = 50

      def initialize
        @buffer = []
      end

      def migrate
        do_migrate
        flush_buffer
      end

      private

      def log_doc(doc)
        identifier = doc['_source']['identifiers']&.select do |i|
          i['schemeName'] == IDENTIFIER_NAME_REG
        end&.min_by { |i| i['id'] }
        puts [
          doc['_index'],
          doc['_id'].ljust(20),
          (identifier ? identifier['id'] : '').ljust(30),
          doc['_source']['name']
        ].join(' ')
      end

      def append_buffer(item)
        @buffer << item
        flush_buffer if @buffer.size >= BUFFER_SIZE
      end

      def flush_buffer
        return if @buffer.empty?

        puts "* FLUSHING #{@buffer.size} items in buffer"
        do_flush_buffer
        @buffer = []
      end
    end
  end
end
