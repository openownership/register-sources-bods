require 'register_sources_bods/id_generators/base'

module RegisterSourcesBods
  module IdGenerators
    class PersonStatement < Base
      def generate_id(record)
        generate_statement_id unique_attributes(record)
      end

      private

      def unique_attributes(record) 
        record.to_h.reject { |k, _v| [:statementID, :statementDate, :publicationDetails, :source].include? k }
      end
    end
  end
end
