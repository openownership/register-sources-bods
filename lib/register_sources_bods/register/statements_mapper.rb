require 'ostruct'
require 'register_sources_bods/structs/bods_statement'
require 'register_sources_bods/register/entity'
require 'register_sources_bods/register/relationship'
require 'register_sources_bods/register/unknown_person_builder'
require 'register_sources_bods/register/paginated_array'

module RegisterSourcesBods
    module Register
        class StatementsMapper
            def initialize(unknown_person_builder: nil)
                @unknown_person_builder = unknown_person_builder || UnknownPersonBuilder.new
            end

            def map_statements(bods_statements)
                entities = {}
                relationships = {}

                # map initial register statements
                bods_statements.values.each do |bods_statement|
                    case bods_statement.statementType
                    when StatementTypes['personStatement']
                        entities[bods_statement.statementID] = Register::Entity.new(bods_statement)
                    when StatementTypes['entityStatement']
                        entities[bods_statement.statementID] = Register::Entity.new(bods_statement)
                    when StatementTypes['ownershipOrControlStatement']
                        relationships[bods_statement.statementID] = Register::Relationship.new(bods_statement)
                    end
                end

                # add merged entities and master entitiy
                replaced_ids = Set.new
                entities.values.each do |entity|
                    next unless entity.bods_statement.respond_to?(:replacesStatements)

                    replaced_ids += entity.bods_statement.replacesStatements
                end

                # compute master entities
                master_entities = {}
                entities.values.each do |entity|
                    next if replaced_ids.include?(entity.id)

                    next unless entity.respond_to?(:identifiers)

                    register_identifier = entity.identifiers.find { |ident| ident.schemeName == "OpenOwnership Register" }

                    next unless register_identifier&.uri

                    master_entities[register_identifier&.uri] = entity.id
                end
                
                # add master_entities and merged entities
                entities.values.each do |entity|
                    next unless entity.respond_to?(:identifiers)

                    register_identifier = entity.identifiers.find { |ident| ident.schemeName == "OpenOwnership Register" }

                    next unless register_identifier&.uri

                    master_statement_id = master_entities[register_identifier&.uri]

                    master_entity = entities[master_statement_id]

                    next unless master_entity

                    if master_statement_id != entity.id
                        # master_entity.merged_entities << entity
                        entity.master_entity = master_entity
                    end
                end

                # add source and target for register
                relationships.values.each do |relationship|
                    bods_statement = relationship.bods_statement

                    subject_statement_id = bods_statement.subject&.describedByEntityStatement
                    interested_party = bods_statement.interestedParty
                    interested_party_statement_id = interested_party&.describedByEntityStatement || interested_party&.describedByPersonStatement

                    # TODO: check direction of source and target
                    # TODO: include master entity

                    source = interested_party_statement_id && entities[interested_party_statement_id]
                    if source
                        source = source.master_entity || source
                        source.relationships_as_source = [source.relationships_as_source, relationship].compact.flatten.uniq
                        relationship.source = source
                    end

                    target = subject_statement_id && entities[subject_statement_id]
                    if target
                        target = target.master_entity || target
                        target.relationships_as_target = [target.relationships_as_target, relationship].compact.flatten.uniq
                        relationship.target = target
                    end
                end

                entities = entities.filter { |_, entity| !entity.master_entity }
                OpenStruct.new(entities: entities, relationships: relationships)
            end

            private

            attr_reader :unknown_person_builder

            def build_unknown_person(bods_statement)
                unknown_person_builder.build bods_statement
            end
        end
    end
end
