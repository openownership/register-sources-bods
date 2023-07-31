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
          identifiers: bods_statement.identifiers.map do |identifier|
            next unless identifier.schemeName == "OpenOwnership Register"

            RegisterSourcesBods::Identifier[{
              id: "#{identifier.id}-unknown",
              scheme: identifier.scheme,
              schemeName: identifier.schemeName,
              uri: "#{identifier.id}-uri",
            }.compact]
          end.compact,
          unspecifiedPersonDetails: UnspecifiedPersonDetails[{
            reason: UnspecifiedReasons['unknown'],
          }],
          publicationDetails: bods_statement.publicationDetails,
          names: [
            Name[{
              fullName: "Unknown person(s)",
            }],
          ],
          source: bods_statement.source,
        }.compact]
      end

      def build_unknown_relationship(bods_statement)
        RegisterSourcesBods::OwnershipOrControlStatement[{
          statementID: "#{bods_statement.statementID}-unknown-rel",
          statementType: StatementTypes['ownershipOrControlStatement'],
          isComponent: false,
          subject: Subject[{
            describedByEntityStatement: bods_statement.statementID,
          }],
          interestedParty: InterestedParty[{
            describedByPersonStatement: "#{bods_statement.statementID}-unknown",
          }],
          interests: [
            Interest.new(
              type: InterestTypes['other-influence-or-control'],
              interestLevel: InterestLevels['unknown'],
            ),
          ],
          publicationDetails: bods_statement.publicationDetails,
          source: bods_statement.source,
        }.compact]
      end
    end
  end
end
