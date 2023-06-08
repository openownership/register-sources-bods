require 'register_sources_bods/register/statements_mapper'

module RegisterSourcesBods
  module Register
    class StatementLoader
      def initialize(statement_repository:, statements_mapper: nil)
        @statement_repository = statement_repository
        @statements_mapper = statements_mapper || StatementsMapper.new
      end

      def load_statements(statement_ids)
        statements = fetch_with_duplicates(statement_ids)
        new_statements = statements

        while !new_statements.empty?
          new_statements = load_associated_statements(new_statements.keys).map { |r| [r.statementID, r] }.to_h.reject { |k,v| statements.key? k }

          next_statement_ids = new_statements.keys

          next_statement_ids += statements.values.select { |s| s.respond_to?(:interestedParty) }.map(&:interestedParty).compact.map(&:describedByEntityStatement).compact
          next_statement_ids += statements.values.select { |s| s.respond_to?(:interestedParty) }.map(&:interestedParty).compact.map(&:describedByPersonStatement).compact
          next_statement_ids += statements.values.select { |s| s.respond_to?(:subject) }.map(&:subject).compact.map(&:describedByEntityStatement).compact

          next_statement_ids = next_statement_ids.uniq - statements.keys

          new_statements = new_statements.merge(
            fetch_with_duplicates(next_statement_ids)
          ).reject { |k,v| statements.key? k }

          statements.merge!(new_statements)
        end

        statements_mapper.map_statements statements
      end

      private

      attr_reader :statement_repository, :statements_mapper

      def load_by_ids(statement_ids)
        statement_repository.get_bulk(statement_ids)
      end

      def load_associated_statements(statement_ids)
        statement_repository.list_associated(statement_ids)
      end

      def load_by_identifiers(identifiers)
        statement_repository.list_matching_at_least_one_identifier(identifiers)
      end

      def fetch_with_duplicates(statement_ids)
        statements = load_by_ids(statement_ids)

        identifiers = statements.map do |statement|
          next unless statement.respond_to?(:identifiers)

          statement.identifiers.find do |identifier|
            identifier.schemeName == "OpenOwnership Register"
          end
        end.compact

        statements += statement_repository.list_matching_at_least_one_identifier(identifiers)

        statements.map { |statement| [statement.statementID, statement] }.to_h
      end
    end
  end
end
