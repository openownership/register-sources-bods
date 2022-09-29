require 'register_sources_bods/types'

require 'register_sources_bods/enums/entity_types'
require 'register_sources_bods/enums/statement_types'
require 'register_sources_bods/structs/annotation'
require 'register_sources_bods/structs/address'
require 'register_sources_bods/structs/unspecified_entity_details'
require 'register_sources_bods/structs/identifier'
require 'register_sources_bods/structs/jurisdiction'
require 'register_sources_bods/structs/publication_details'
require 'register_sources_bods/structs/source'
require 'register_sources_bods/structs/statement_date'

module RegisterSourcesBods
  class EntityStatement < Dry::Struct
    transform_keys(&:to_sym)

    attribute :statementID, Types::String
    attribute :statementType, StatementTypes
    attribute? :statementDate, StatementDate
    attribute :isComponent, Types::Params::Bool
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
