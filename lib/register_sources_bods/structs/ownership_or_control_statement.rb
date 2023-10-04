# frozen_string_literal: true

require_relative '../enums/statement_types'
require_relative '../types'
require_relative 'annotation'
require_relative 'interest'
require_relative 'interested_party'
require_relative 'publication_details'
require_relative 'source'
require_relative 'statement_date'
require_relative 'subject'

module RegisterSourcesBods
  class OwnershipOrControlStatement < Dry::Struct
    transform_keys(&:to_sym)

    attribute? :statementID,           Types::String.optional
    attribute  :statementType,         StatementTypes
    attribute? :statementDate,         StatementDate
    attribute  :isComponent,           Types::Params::Bool
    attribute? :componentStatementIDs, Types.Array(Types::String)
    attribute  :subject,               Subject
    attribute  :interestedParty,       InterestedParty
    attribute? :interests,             Types.Array(Interest)
    attribute? :publicationDetails,    PublicationDetails
    attribute? :source,                Source
    attribute? :annotations,           Types.Array(Annotation)
    attribute? :replacesStatements,    Types.Array(Types::String)
  end
end
