require 'register_bods_v2/types'

require 'register_bods_v2/enums/person_types'
require 'register_bods_v2/enums/statement_types'
require 'register_bods_v2/structs/annotation'
require 'register_bods_v2/structs/pep_status_details'
require 'register_bods_v2/structs/publication_details'
require 'register_bods_v2/structs/source'

module RegisterBodsV2
  class PersonStatement < Dry::Struct
    attribute :statementID, Types::String.optional
    attribute :statementType, StatementTypes
    attribute :statementDate, Types::String.optional
    attribute :isComponent, Types::String.optional
    attribute :personType, PersonTypes
    attribute :unspecifiedPersonDetails, Types::String.optional
    attribute :names, Types::String.optional
    attribute :identifiers, Types::String.optional
    attribute :nationalities, Types::String.optional
    attribute :placeOfBirth, Types::String.optional
    attribute :birthDate, Types::String.optional
    attribute :deathDate, Types::String.optional
    attribute :placeOfResidence, Types::String.optional
    attribute :taxResidencies, Types::String.optional
    attribute :addresses, Types::String.optional
    attribute :hasPepStatus, Types::String.optional
    attribute :pepStatusDetails, PepStatusDetails.optional
    attribute :publicationDetails, PublicationDetails.optional
    attribute :source, Source.optional
    attribute :annotations, Types.Array(Annotation)
    attribute :replacesStatements, Types::String.optional
  )
end
