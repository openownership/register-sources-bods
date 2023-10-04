# frozen_string_literal: true

require_relative '../enums/person_types'
require_relative '../enums/statement_types'
require_relative '../types'
require_relative 'address'
require_relative 'annotation'
require_relative 'country'
require_relative 'identifier'
require_relative 'name'
require_relative 'pep_status_details'
require_relative 'publication_details'
require_relative 'source'
require_relative 'statement_date'
require_relative 'unspecified_person_details'

module RegisterSourcesBods
  class PersonStatement < Dry::Struct
    transform_keys(&:to_sym)

    attribute? :statementID,              Types::String.optional
    attribute  :statementType,            StatementTypes
    attribute? :statementDate,            StatementDate
    attribute  :isComponent,              Types::Params::Bool
    attribute  :personType,               PersonTypes
    attribute? :unspecifiedPersonDetails, UnspecifiedPersonDetails
    attribute? :names,                    Types.Array(Name)
    attribute? :identifiers,              Types.Array(Identifier)
    attribute? :nationalities,            Types.Array(Country)
    attribute? :placeOfBirth,             Address
    attribute? :birthDate,                Types::String.optional
    attribute? :deathDate,                Types::String.optional
    attribute? :placeOfResidence,         Address
    attribute? :taxResidencies,           Types.Array(Country)
    attribute? :addresses,                Types.Array(Address)
    attribute? :hasPepStatus,             Types::Params::Bool
    attribute? :pepStatusDetails,         PepStatusDetails
    attribute? :publicationDetails,       PublicationDetails
    attribute? :source,                   Source
    attribute? :annotations,              Types.Array(Annotation)
    attribute? :replacesStatements,       Types.Array(Types::String)
  end
end
