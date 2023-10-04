# frozen_string_literal: true

require_relative '../enums/entity_types'
require_relative '../enums/statement_types'
require_relative '../types'
require_relative 'address'
require_relative 'annotation'
require_relative 'identifier'
require_relative 'jurisdiction'
require_relative 'publication_details'
require_relative 'source'
require_relative 'statement_date'
require_relative 'unspecified_entity_details'

module RegisterSourcesBods
  class EntityStatement < Dry::Struct
    transform_keys(&:to_sym)

    attribute? :statementID,                Types::String
    attribute  :statementType,              StatementTypes
    attribute? :statementDate,              StatementDate
    attribute  :isComponent,                Types::Params::Bool
    attribute  :entityType,                 EntityTypes
    attribute? :unspecifiedEntityDetails,   UnspecifiedEntityDetails
    attribute? :name,                       Types::String
    attribute? :alternateNames,             Types::String
    attribute? :incorporatedInJurisdiction, Jurisdiction
    attribute? :identifiers,                Types.Array(Identifier)
    attribute? :foundingDate,               StatementDate
    attribute? :dissolutionDate,            StatementDate
    attribute? :addresses,                  Types.Array(Address)
    attribute? :uri,                        Types::String
    attribute? :replacesStatements,         Types.Array(Types::String)
    attribute? :publicationDetails,         PublicationDetails
    attribute? :source,                     Source
    attribute? :annotations,                Types.Array(Annotation)
  end
end
