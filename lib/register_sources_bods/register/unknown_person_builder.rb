require 'register_sources_bods/structs/person_statement'
require 'register_sources_bods/register/unknown_entity'

module RegisterSourcesBods
    module Register
        class UnknownPersonBuilder
            def build(bods_statement)
                RegisterSourcesBods::PersonStatement[{
                    statementID: "#{bods_statement.statementID}-unknown",
                    statementType: StatementTypes['personStatement'],
                    isComponent: false,
                    personType: PersonTypes['unknownPerson'],
                    unspecifiedPersonDetails: UnspecifiedPersonDetails[{
                        reason: UnspecifiedReasons['unknown'],
                    }],
                    publicationDetails: bods_statement.publicationDetails,
                    names: [
                        Name[{
                            fullName: "unknown_persons_entity.names.unknown", # TODO
                        }],
                    ],
                }.compact]
            end
        end
    end
end
