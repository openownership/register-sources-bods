require 'register_sources_bods/id_generators/base'

module RegisterSourcesBods
  module IdGenerators
    class EntityStatement < Base
      def generate_id(record)
        generate_statement_id unique_attributes(record)
      end

      private

      def unique_attributes(record)
        record_h = record.to_h

        record_h[:identifiers] = record_h[:identifiers].reject { |identifier| identifier[:schemeName] == 'OpenOwnership Register' }

        record_h.reject { |k, _v| [:statementID, :statementDate, :publicationDetails, :source, :replacesStatements].include? k }
      end
    end
  end
end
