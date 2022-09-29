require 'register_sources_bods/types'

require 'register_sources_bods/enums/statement_types'
require 'register_sources_bods/structs/annotation'
require 'register_sources_bods/structs/interest'
require 'register_sources_bods/structs/interested_party'
require 'register_sources_bods/structs/publication_details'
require 'register_sources_bods/structs/source'
require 'register_sources_bods/structs/statement_date'
require 'register_sources_bods/structs/subject'

module RegisterSourcesBods
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
