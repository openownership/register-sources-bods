require 'ostruct'
require 'register_sources_bods/structs/bods_statement'
require 'register_sources_bods/register/entity'
require 'register_sources_bods/register/relationship'

module RegisterSourcesBods
    module Register
        class StatementsMapper
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
                        entities[bods_statement.statementID] = Register::Relationship.new(bods_statement)
                    end
                end

                # add source and target for register
                relationships.values.each do |relationship|
                    bods_statement = relationship.bods_statement

                    subject_statement_id = bods_statement.subject&.describedByEntityStatement
                    interested_party = bods_statement.interested_party
                    interested_party_statement_id = interested_party&.describedByEntityStatement || interested_party&.describedByPersonStatement

                    # TODO: check direction of source and target

                    source = subject_statement_id && entities[subject_statement_id]
                    source.relationships_as_source = [source.relationships_as_source, relationship].compact.flatten.uniq
                    relationship.source = source

                    target = interested_party_statement_id && entities[subject_statement_id]
                    target.relationships_as_target = [target.relationships_as_target, relationship].compact.flatten.uniq
                    relationship.target = target
                end

                # add merged entities and master entitiy
                entities.values.each do |entity|
                    register_identifier = entity.identifiers.find { |ident| ident.schemeName == "OpenOwnership Register" }

                    next unless register_identifier&.uri

                    # extract statement id from uri
                    master_statement_id = register_identifier.uri.split("/").last

                    master_entity = entities[master_statement_id]

                    next unless master_entity

                    if master_statement_id != entity.id
                        master_entity.merged_entities << entity
                        entity.master_entity = master_entity
                    end
                end

                OpenStruct.new(entities: entities, relationships: relationships)
            end
        end
    end
end
