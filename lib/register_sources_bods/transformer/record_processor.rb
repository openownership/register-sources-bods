require 'register_sources_bods/transformer/entity_statement'
require 'register_sources_bods/transformer/ownership_or_control_statement'

module RegisterSourcesBods
  module Transformer
    class RecordProcessor
      def initialize(
        entity_resolver: nil,
        raw_records_repository:,
        entity_statement_mapper: Transformer::EntityStatement,
        ownership_or_control_statement_mapper: Transformer::OwnershipOrControlStatement,
        bods_publisher: nil
      )
        @entity_resolver = entity_resolver
        @raw_records_repository = raw_records_repository
        @entity_statement_mapper = entity_statement_mapper
        @ownership_or_control_statement_mapper = ownership_or_control_statement_mapper
        @bods_publisher = bods_publisher
      end

      def process(bods_record)
        process_many([bods_record])
      end

      def process_many(bods_records)
        # Load any related statements
        bods_records += raw_records_repository.list_associated(bods_records.map(&:statementID))
        bods_records = bods_records.uniq(&:statementID)
        
        # Construct Entities
        entity_type = RegisterSourcesBods::StatementTypes['entityStatement']
        entities = bods_records.filter { |bods_record| bods_record.statementType == entity_type }
        entities = entities.to_h { |bods_record| [bods_record.statementID, map_entity(bods_record)] }

        # Construct Persons
        person_type = RegisterSourcesBods::StatementTypes['personStatement']
        persons = bods_records.filter { |bods_record| bods_record.statementType == person_type }
        persons = persons.to_h { |bods_record| [bods_record.statementID, bods_record] }

        # Publish Entities and Persons
        published_entities = bods_publisher.publish_many(entities.compact.merge(persons))

        # Construct Relationships
        ownership_or_control_type = RegisterSourcesBods::StatementTypes['ownershipOrControlStatement']
        relationships = bods_records.filter { |bods_record| bods_record.statementType == ownership_or_control_type }
        relationships = relationships.map do |bods_record|
          # Find published child entity
          parent_statement_id = [
            bods_record.interestedParty&.describedByEntityStatement,
            bods_record.interestedParty&.describedByPersonStatement,
          ].compact.first
          published_parent_entity = published_entities[parent_statement_id]

          # Find published child entity
          child_statement_id = bods_record.subject&.describedByEntityStatement
          published_child_entity = published_entities[child_statement_id]

          next unless published_child_entity && published_parent_entity

          [
            bods_record.statementID,
            map_relationship(bods_record, published_child_entity, published_parent_entity)
          ]
        end.compact.to_h.compact

        # Publish Relationships
        bods_publisher.publish_many(relationships)
      end

      private

      attr_reader :entity_resolver, :bods_publisher, :raw_records_repository,
                  :entity_statement_mapper, :ownership_or_control_statement_mapper

      def map_entity(bods_record)
        entity_statement_mapper.call(bods_record, entity_resolver:)
      end

      def map_relationship(bods_record, child_entity, parent_entity)
        return unless child_entity && parent_entity

        ownership_or_control_statement_mapper.call(
          bods_record,
          source_statement: parent_entity,
          target_statement: child_entity,
        )
      end
    end
  end
end
