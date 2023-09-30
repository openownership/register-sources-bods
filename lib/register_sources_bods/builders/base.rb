# frozen_string_literal: true

module RegisterSourcesBods
  module Builders
    class Base
      def initialize(id_generator)
        @id_generator = id_generator
      end

      # def build(record, replaces_ids: [])

      private

      attr_reader :id_generator

      def generate_statement_id(record)
        id_generator.generate_id record
      end
    end
  end
end
