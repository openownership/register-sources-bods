require 'register_bods_v2/types'

require 'register_bods_v2/enums/statement_types'
require 'register_bods_v2/structs/annotation'
require 'register_bods_v2/structs/interested_party'
require 'register_bods_v2/structs/publication_details'
require 'register_bods_v2/structs/source'
require 'register_bods_v2/structs/subject'

module RegisterBodsV2
  class OwnershipOrControlStatement < Dry::Struct
    attribute :statementID, Types::String.optional
    attribute :statementType, StatementTypes
    attribute :statementDate,	Types::String.optional
    attribute :isComponent, Types::String.optional
    attribute :componentStatementIDs, Types.Array(Types::String).optional
    attribute :subject, Subject.optional
    attribute :interestedParty, InterestedParty.optional
    attribute :interests, Types::String.optional
    attribute :publicationDetails, PublicationDetails.optional
    attribute :source, Source.optional
    attribute :annotations, Types.Array(Annotation)
    attribute :replacesStatements, Types::String.optional
  end
end
