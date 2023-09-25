# frozen_string_literal: true

require 'register_sources_bods/types'

require 'register_sources_bods/enums/person_types'
require 'register_sources_bods/enums/statement_types'
require 'register_sources_bods/structs/statement_date'
require 'register_sources_bods/structs/address'
require 'register_sources_bods/structs/annotation'
require 'register_sources_bods/structs/country'
require 'register_sources_bods/structs/identifier'
require 'register_sources_bods/structs/name'
require 'register_sources_bods/structs/pep_status_details'
require 'register_sources_bods/structs/publication_details'
require 'register_sources_bods/structs/source'
require 'register_sources_bods/structs/unspecified_person_details'

module RegisterSourcesBods
  class PersonStatement < Dry::Struct
    transform_keys(&:to_sym)

    attribute? :statementID, Types::String.optional
    attribute :statementType, StatementTypes
    attribute? :statementDate, StatementDate
    attribute :isComponent, Types::Params::Bool
    attribute :personType, PersonTypes
    attribute? :unspecifiedPersonDetails, UnspecifiedPersonDetails
    attribute? :names, Types.Array(Name)
    attribute? :identifiers, Types.Array(Identifier)
    attribute? :nationalities, Types.Array(Country)
    attribute? :placeOfBirth, Address
    attribute? :birthDate, Types::String.optional
    attribute? :deathDate, Types::String.optional
    attribute? :placeOfResidence, Address
    attribute? :taxResidencies, Types.Array(Country)
    attribute? :addresses, Types.Array(Address)
    attribute? :hasPepStatus, Types::Params::Bool
    attribute? :pepStatusDetails, PepStatusDetails
    attribute? :publicationDetails, PublicationDetails
    attribute? :source, Source
    attribute? :annotations, Types.Array(Annotation)
    attribute? :replacesStatements, Types.Array(Types::String)
  end
end
