# frozen_string_literal: true

require 'register_sources_bods/id_generators/base'

module RegisterSourcesBods
  module IdGenerators
    class PersonStatement < Base
      def generate_id(record)
        generate_statement_id unique_attributes(record)
      end

      private

      def unique_attributes(record)
        record_h = record.to_h

        record_h.except(:statementID, :statementDate, :publicationDetails, :source, :replacesStatements)
      end
    end
  end
end
