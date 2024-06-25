# frozen_string_literal: true

require_relative '../constants/identifiers'

module RegisterSourcesBods
  module Migrations
    class Base
      BUFFER_SIZE = 50

      def initialize
        @buffer = []
        @n = 0
      end

      def migrate
        do_migrate
        flush_buffer
      end

      private

      def log_doc(doc)
        @n += 1
        fs = if doc['_source']['statementType']
               replaced = doc['_source']['metadata.replaced'] ? 'R' : '-'
               [
                 format('%9s', @n),
                 doc['_index'],
                 doc['_id'].ljust(20),
                 replaced,
                 doc['_source']['statementType'].ljust(27),
                 doc['_source']['name']
               ]
             elsif doc['_source']['identifier_system_code']
               [
                 format('%9s', @n),
                 doc['_index'],
                 doc['_id'].ljust(20),
                 doc['_source']['identifier_system_code']
               ]
             else
               [
                 format('%9s', @n),
                 doc['_index'],
                 doc['_id'].ljust(20)
               ]
             end
        puts fs.join(' ')
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
