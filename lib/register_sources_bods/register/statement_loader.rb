require 'register_sources_bods/register/statements_mapper'

module RegisterSourcesBods
  module Register
    class StatementLoader
      MAX_LEVELS = 8
      SLICE_SIZE = 50

      def initialize(statement_repository:, statements_mapper: nil)
        @statement_repository = statement_repository
        @statements_mapper = statements_mapper || StatementsMapper.new
      end

      def load_statements(statement_ids, load_children: true)
        statements = fetch_with_duplicates(statement_ids)

        if load_children
          child_statements = load_statements_children(statements)
          parent_statements = load_statements_parents(statements)

          statements.merge!(child_statements).merge!(parent_statements)
        end

        statements_mapper.map_statements statements
      end

      private

      attr_reader :statement_repository, :statements_mapper

      def load_statements_children(statements)
        new_statements = statements

        level = 0
        while !new_statements.empty? && (level <= MAX_LEVELS)
          new_statements = load_associated_statements(new_statements.keys, interested_party: false, subject: true).to_h { |r| [r.statementID, r] }.reject { |k, _v| statements.key? k }

          next_statement_ids = new_statements.keys

          next_statement_ids += statements.values.select { |s| s.respond_to?(:interestedParty) }.map(&:interestedParty).compact.map(&:describedByEntityStatement).compact
          next_statement_ids += statements.values.select { |s| s.respond_to?(:interestedParty) }.map(&:interestedParty).compact.map(&:describedByPersonStatement).compact
          next_statement_ids += new_statements.values.select { |s| s.respond_to?(:interestedParty) }.map(&:interestedParty).compact.map(&:describedByEntityStatement).compact
          next_statement_ids += new_statements.values.select { |s| s.respond_to?(:interestedParty) }.map(&:interestedParty).compact.map(&:describedByPersonStatement).compact

          next_statement_ids = next_statement_ids.uniq - statements.keys

          new_statements = new_statements.merge(
            fetch_with_duplicates(next_statement_ids),
          ).reject { |k, _v| statements.key? k }

          statements = statements.merge(new_statements)
          level += 1
        end

        statements
      end

      def load_statements_parents(statements)
        new_statements = statements

        level = 0
        while !new_statements.empty? && (level <= MAX_LEVELS)
          new_statements = load_associated_statements(new_statements.keys, interested_party: true, subject: false).to_h { |r| [r.statementID, r] }.reject { |k, _v| statements.key? k }

          next_statement_ids = new_statements.keys

          next_statement_ids += statements.values.select { |s| s.respond_to?(:subject) }.map(&:subject).compact.map(&:describedByEntityStatement).compact
          next_statement_ids += new_statements.values.select { |s| s.respond_to?(:subject) }.map(&:subject).compact.map(&:describedByEntityStatement).compact

          next_statement_ids = next_statement_ids.uniq - statements.keys

          new_statements = new_statements.merge(
            fetch_with_duplicates(next_statement_ids),
          ).reject { |k, _v| statements.key? k }

          statements = statements.merge(new_statements)
          level += 1
        end

        statements
      end

      def load_by_ids(statement_ids)
        statement_repository.get_bulk(statement_ids)
      end

      def load_associated_statements(all_statement_ids, interested_party: true, subject: true)
        results = []

        all_statement_ids.each_slice(SLICE_SIZE) do |statement_ids|
          results += statement_repository.list_associated(statement_ids, interested_party:, subject:)
        end

        results
      end

      def load_by_identifiers(identifiers)
        statement_repository.list_matching_at_least_one_identifier(identifiers)
      end

      def fetch_with_duplicates(all_statement_ids)
        results = {}

        all_statement_ids.each_slice(SLICE_SIZE) do |statement_ids|
          statements = load_by_ids(statement_ids)

          identifiers = statements.map do |statement|
            next unless statement.respond_to?(:identifiers)

            statement.identifiers.find do |identifier|
              identifier.schemeName == "OpenOwnership Register"
            end
          end.compact

          statements += statement_repository.list_matching_at_least_one_identifier(identifiers)

          results.merge!(
            statements.to_h { |statement| [statement.statementID, statement] },
          )
        end

        results
      end
    end
  end
end
