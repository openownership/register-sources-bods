require 'register_sources_bods/register/statements_mapper'
require 'register_sources_bods/register/entity_query_builder'

module RegisterSourcesBods
  module Register
    class StatementLoader
      def initialize(statement_repository:, statements_mapper: nil, query_builder: EntityQueryBuilder.new)
        @statement_repository = statement_repository
        @entity_query_builder = query_builder
        @statements_mapper = statements_mapper || StatementsMapper.new
      end

      def load_statements(statement_ids)
        initial_statements = load_statements_without_merges(statement_ids)

        person_statements = initial_statements.entities.values.filter { |statement| statement.natural_person? }

        return initial_statements unless person_statements

        person_statements.each do |natural_person|
          similar_people_query = entity_query_builder.build_merged_query(natural_person.bods_statement)

          people = statement_repository.search(similar_people_query).map(&:record)

          next if people.empty?

          loaded_people = load_statements_without_merges(people.map(&:statementID)).entities.values

          print "Loaded some people\n"

          all_people = [natural_person, loaded_people].flatten

          min_id = all_people.map(&:id).min
          master_entity = all_people.find { |person| person.id == min_id }

          print "Calculated master entity\n"

          all_people.each do |person|
            print "Looping for first person\n"
            all_people.each do |person2|
              next unless person2.id > person.id

              print "Looping for second person\n"
              if person.id != min_id
                person.master_entity = master_entity
              end

              if person2.id != min_id
                person2.master_entity = master_entity
              end

              person.merged_entities << person2
              person2.merged_entities << person

              new_relationships_as_sources = person.relationships_as_source + person2.relationships_as_source
              new_relationships_as_targets = person.relationships_as_target + person2.relationships_as_target

              person.relationships_as_source = new_relationships_as_sources
              person2.relationships_as_source = new_relationships_as_sources
              person.relationships_as_target = new_relationships_as_targets
              person2.relationships_as_target = new_relationships_as_targets
            end
          end

          print "Performed updates\n"
        end

        print "Added some people relationships\n"

        initial_statements
      end

      def load_statements_without_merges(statement_ids)
        processed_ids = []

        all_statements = {}

        next_statement_ids = statement_ids.dup

        until next_statement_ids.empty?
          statements = single_loader(next_statement_ids, processed_ids:)

          all_statements.merge!(statements)

          processed_ids = (processed_ids + next_statement_ids + statements.values.map(&:statementID)).uniq

          next_statement_ids = []

          next_statement_ids += statements.values.select { |s| s.respond_to?(:interestedParty) }.map(&:interestedParty).compact.map(&:describedByEntityStatement).compact
          next_statement_ids += statements.values.select { |s| s.respond_to?(:interestedParty) }.map(&:interestedParty).compact.map(&:describedByPersonStatement).compact
          next_statement_ids += statements.values.select { |s| s.respond_to?(:subject) }.map(&:subject).compact.map(&:describedByEntityStatement).compact

          next_statement_ids = next_statement_ids.uniq - processed_ids
        end

        statements_mapper.map_statements all_statements
      end

      private

      attr_reader :statement_repository, :statements_mapper, :entity_query_builder

      def load_by_ids(statement_ids)
        statement_repository.get_bulk(statement_ids)
      end

      def load_associated_statements(statement_ids)
        statement_repository.list_associated(statement_ids)
      end

      def load_by_identifiers(identifiers)
        statement_repository.list_matching_at_least_one_identifier(identifiers)
      end

      def single_loader(statement_ids, processed_ids: [])
        statement_ids = statement_ids.uniq - processed_ids

        # load by id
        statements = load_by_ids(statement_ids) + load_associated_statements(statement_ids)

        # load additional statements using identifiers
        identifiers = statements.map do |statement|
          next unless statement.respond_to?(:identifiers)

          statement.identifiers.find do |identifier|
            identifier.schemeName == "OpenOwnership Register"
          end
        end.compact

        statements += statement_repository.list_matching_at_least_one_identifier(identifiers)

        statements.to_h { |statement| [statement.statementID, statement] }
      end
    end
  end
end
