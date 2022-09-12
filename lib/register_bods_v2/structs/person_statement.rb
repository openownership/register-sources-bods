require 'register_bods_v2/types'

require 'register_bods_v2/enums/person_types'
require 'register_bods_v2/enums/statement_types'
require 'register_bods_v2/structs/statement_date'
require 'register_bods_v2/structs/address'
require 'register_bods_v2/structs/annotation'
require 'register_bods_v2/structs/country'
require 'register_bods_v2/structs/identifier'
require 'register_bods_v2/structs/name'
require 'register_bods_v2/structs/pep_status_details'
require 'register_bods_v2/structs/publication_details'
require 'register_bods_v2/structs/source'
require 'register_bods_v2/structs/unspecified_person_details'

module RegisterBodsV2
  class PersonStatement < Dry::Struct
    transform_keys(&:to_sym)

    attribute :statementID, Types::String.optional # TODO: Statement Identitifer
    attribute :statementType, StatementTypes
    attribute? :statementDate, StatementDate
    attribute :isComponent,  Types::Nominal::Bool
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
    attribute? :hasPepStatus, Types::Nominal::Bool
    attribute? :pepStatusDetails, PepStatusDetails
    attribute :publicationDetails, PublicationDetails
    attribute? :source, Source
    attribute? :annotations, Types.Array(Annotation)
    attribute? :replacesStatements, Types::String.optional
  end
end
