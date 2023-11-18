# frozen_string_literal: true

require 'ostruct'

require_relative '../constants/identifiers'
require_relative '../structs/bods_statement'
require_relative 'entity'
require_relative 'paginated_array'
require_relative 'relationship'
require_relative 'unknown_person_builder'

module RegisterSourcesBods
  module Register
    class StatementsMapper
      def initialize(unknown_person_builder: nil)
        @unknown_person_builder = unknown_person_builder || UnknownPersonBuilder.new
      end

      # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Style/CombinableLoops
      def map_statements(bods_statements)
        entities, relationships = split_statements_into_entities_and_relationships(bods_statements)

        # add merged entities and master entitiy
        replaced_ids = Set.new
        entities.each_value do |entity|
          next unless entity.bods_statement.respond_to?(:replacesStatements)

          replaced_ids += entity.bods_statement.replacesStatements
        end

        # compute master entities
        master_statement_ids = {}
        entities.each_value do |entity|
          register_identifier = entity.identifiers.find do |ident|
            ident.schemeName == IDENTIFIER_NAME_REG
          end

          next unless register_identifier&.uri

          next if replaced_ids.include? entity.bods_statement.statementID

          master_statement_ids[register_identifier&.uri] = entity.bods_statement.statementID
        end

        entities.each_value do |entity|
          register_identifier = entity.identifiers.find do |ident|
            ident.schemeName == IDENTIFIER_NAME_REG
          end

          next unless register_identifier&.uri

          master_statement_id = master_statement_ids[register_identifier&.uri]

          master_entity = entities[master_statement_id]

          next unless master_entity

          if master_statement_id != entity.bods_statement.statementID
            master_entity.replaced_bods_statements << entity.bods_statement
            entity.master_entity = master_entity
          end
        end

        # add source and target for register
        relationships.each_value do |relationship|
          bods_statement = relationship.bods_statement

          subject_statement_id = bods_statement.subject&.describedByEntityStatement
          interested_party = bods_statement.interestedParty
          interested_party_statement_id = interested_party&.describedByEntityStatement ||
                                          interested_party&.describedByPersonStatement

          source = interested_party_statement_id && entities[interested_party_statement_id]
          if source
            source = source.master_entity || source
            source.relationships_as_source = [source.relationships_as_source, relationship].compact.flatten.uniq
            relationship.source = source
          end

          target = subject_statement_id && entities[subject_statement_id]

          next unless target

          target = target.master_entity || target
          target.relationships_as_target = [target.relationships_as_target, relationship].compact.flatten.uniq
          relationship.target = target
        end

        # build unknown

        unknown_entities = {}
        entities.each_value do |entity|
          next if entity.natural_person?
          next unless (entity.relationships_as_target || []).empty?

          unknown_bods_statement = unknown_person_builder.build entity.bods_statement
          unknown_relationship_statement = unknown_person_builder.build_unknown_relationship entity.bods_statement

          unknown_entity = Register::Entity.new(unknown_bods_statement)
          unknown_rel = Register::Relationship.new(unknown_relationship_statement)
          unknown_rel.source = unknown_entity
          unknown_rel.target = entity
          unknown_entity.relationships_as_source = [unknown_rel]
          entity.relationships_as_target = [unknown_rel]

          unknown_entities[unknown_entity.bods_statement.statementID] = unknown_entity
          relationships[unknown_rel.bods_statement.statementID] = unknown_rel
        end

        entities = entities.filter { |_, entity| !entity.master_entity }.merge(unknown_entities)
        OpenStruct.new(entities:, relationships:) # rubocop:disable Style/OpenStructUse
      end
      # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Style/CombinableLoops

      private

      attr_reader :unknown_person_builder

      def split_statements_into_entities_and_relationships(bods_statements)
        entities = {}
        relationships = {}

        # map initial register statements
        bods_statements.each_value do |bods_statement|
          case bods_statement.statementType
          when StatementTypes['entityStatement'], StatementTypes['personStatement']
            entities[bods_statement.statementID] = Register::Entity.new(bods_statement)
          when StatementTypes['ownershipOrControlStatement']
            relationships[bods_statement.statementID] = Register::Relationship.new(bods_statement)
          end
        end

        [entities, relationships]
      end
    end
  end
end
