require 'register_bods_v2/types'

require 'register_bods_v2/enums/statement_types'
require 'register_bods_v2/structs/annotation'
require 'register_bods_v2/structs/interest'
require 'register_bods_v2/structs/interested_party'
require 'register_bods_v2/structs/publication_details'
require 'register_bods_v2/structs/source'
require 'register_bods_v2/structs/statement_date'
require 'register_bods_v2/structs/subject'

module RegisterBodsV2
  class OwnershipOrControlStatement < Dry::Struct
    transform_keys(&:to_sym)

    attribute :statementID, Types::String.optional
    attribute :statementType, StatementTypes
    attribute? :statementDate,	StatementDate
    attribute :isComponent, Types::Params::Bool
    attribute? :componentStatementIDs, Types.Array(Types::String)
    attribute :subject, Subject
    attribute :interestedParty, InterestedParty
    attribute? :interests, Types.Array(Interest)
    attribute :publicationDetails, PublicationDetails
    attribute? :source, Source
    attribute? :annotations, Types.Array(Annotation)
    attribute? :replacesStatements, Types.Array(Types::String)
  end
end
