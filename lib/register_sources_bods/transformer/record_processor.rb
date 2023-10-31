# frozen_string_literal: true

require 'register_sources_bods/transformer/entity_statement'
require 'register_sources_bods/transformer/person_statement'
require 'register_sources_bods/transformer/ownership_or_control_statement'

module RegisterSourcesBods
  module Transformer
    class RecordProcessor
      def initialize(
        raw_records_repository:,
        entity_resolver: nil,
        bods_publisher: nil
      )
        @entity_resolver = entity_resolver
        @raw_records_repository = raw_records_repository
        @bods_publisher = bods_publisher
        @entity_statement_mapper = Transformer::EntityStatement
        @person_statement_mapper = Transformer::PersonStatement
        @ownership_or_control_statement_mapper = Transformer::OwnershipOrControlStatement
      end

      def process(bods_record)
        process_many([bods_record])
      end

      def process_many(bods_records)
        bods_records = load_with_associated_records(bods_records)

        entities = build_entities(bods_records)
        persons = build_persons(bods_records)

        published_entities = bods_publisher.publish_many(entities.compact.merge(persons))

        relationships = build_relationships(bods_records, published_entities)

        bods_publisher.publish_many(relationships)
      end

      private

      attr_reader :entity_resolver, :bods_publisher, :raw_records_repository,
                  :entity_statement_mapper, :person_statement_mapper, :ownership_or_control_statement_mapper

      def load_with_associated_records(bods_records)
        ownership_or_control_type = RegisterSourcesBods::StatementTypes['ownershipOrControlStatement']

        referenced_statement_ids = bods_records.filter do |bods_record|
          bods_record.statementType == ownership_or_control_type
        end.map do |bods_record|
          [
            bods_record.interestedParty&.describedByEntityStatement,
            bods_record.interestedParty&.describedByPersonStatement,
            bods_record.subject&.describedByEntityStatement
          ].compact
        end.flatten.uniq

        bods_records += raw_records_repository.get_bulk(referenced_statement_ids)
        bods_records.uniq(&:statementID)
      end

      def build_entities(bods_records)
        entity_type = RegisterSourcesBods::StatementTypes['entityStatement']
        entities = bods_records.filter { |bods_record| bods_record.statementType == entity_type }
        entities.to_h { |bods_record| [bods_record.statementID, map_entity(bods_record)] }
      end

      def build_persons(bods_records)
        person_type = RegisterSourcesBods::StatementTypes['personStatement']
        persons = bods_records.filter { |bods_record| bods_record.statementType == person_type }
        persons.to_h { |bods_record| [bods_record.statementID, map_person(bods_record)] }
      end

      def build_relationships(bods_records, published_entities)
        relationships = bods_records.filter do |bods_record|
          bods_record.statementType == RegisterSourcesBods::StatementTypes['ownershipOrControlStatement']
        end

        relationships.map do |bods_record|
          published_parent_entity = published_entities[interested_party_id(bods_record)]
          published_child_entity = published_entities[subject_id(bods_record)]

          next unless published_child_entity && published_parent_entity

          [
            bods_record.statementID,
            map_relationship(bods_record, published_child_entity, published_parent_entity)
          ]
        end.compact.to_h.compact
      end

      def interested_party_id(bods_record)
        [
          bods_record.interestedParty&.describedByEntityStatement,
          bods_record.interestedParty&.describedByPersonStatement
        ].compact.first
      end

      def subject_id(bods_record)
        bods_record.subject&.describedByEntityStatement
      end

      def map_entity(bods_record)
        entity_statement_mapper.call(bods_record, entity_resolver:)
      end

      def map_person(bods_record)
        person_statement_mapper.call(bods_record)
      end

      def map_relationship(bods_record, child_entity, parent_entity)
        return unless child_entity && parent_entity

        ownership_or_control_statement_mapper.call(
          bods_record,
          source_statement: parent_entity,
          target_statement: child_entity
        )
      end
    end
  end
end
