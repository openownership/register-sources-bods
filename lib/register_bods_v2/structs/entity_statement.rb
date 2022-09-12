require 'register_bods_v2/types'

require 'register_bods_v2/enums/entity_types'
require 'register_bods_v2/enums/statement_types'
require 'register_bods_v2/structs/annotation'
require 'register_bods_v2/structs/address'
require 'register_bods_v2/structs/unspecified_entity_details'
require 'register_bods_v2/structs/identifier'
require 'register_bods_v2/structs/jurisdiction'
require 'register_bods_v2/structs/publication_details'
require 'register_bods_v2/structs/source'
require 'register_bods_v2/structs/statement_date'

module RegisterBodsV2
  class EntityStatement < Dry::Struct
    transform_keys(&:to_sym)

    attribute :statementID, Types::String
    attribute :statementType, StatementTypes
    attribute? :statementDate, StatementDate
    attribute :isComponent, Types::Nominal::Bool
    attribute :entityType, EntityTypes
    attribute? :unspecifiedEntityDetails, UnspecifiedEntityDetails
    attribute? :name, Types::String
    attribute? :alternateNames, Types::String
    attribute? :incorporatedInJurisdiction, Jurisdiction
    attribute? :identifiers, Types.Array(Identifier)
    attribute? :foundingDate, StatementDate
    attribute? :dissolutionDate, StatementDate
    attribute? :addresses, Types.Array(Address)
    attribute? :uri, Types::String
    attribute? :replacesStatements, Types.Array(Types::String)
    attribute :publicationDetails, PublicationDetails
    attribute? :source, Source
    attribute? :annotations, Types.Array(Annotation)
  end
end
