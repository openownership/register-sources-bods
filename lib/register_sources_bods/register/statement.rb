# frozen_string_literal: true

module RegisterSourcesBods
  module Register
    class Statement
      def initialize(bods_statement)
        @bods_statement = bods_statement

        @entity = nil
      end

      attr_reader :bods_statement

      attr_accessor :entity

      def _id
        nil
      end

      def type
        nil
      end

      def date
        nil
      end

      def ended_date
        nil
      end

      # ASSOCIATIONS

      def entity_id
        entity&.id
      end
    end
  end
end
