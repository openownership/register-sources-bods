require 'register_bods_v2/types'

require 'register_bods_v2/enums/entity_types'
require 'register_bods_v2/enums/statement_types'
require 'register_bods_v2/structs/annotation'
require 'register_bods_v2/structs/address'
require 'register_bods_v2/structs/identifier'
require 'register_bods_v2/structs/publication_details'
require 'register_bods_v2/structs/source'

module RegisterBodsV2
  class EntityStatement < Dry::Struct
    transform_keys(&:to_sym)

    attribute :statementID, Types::String.optional
    attribute :statementType, StatementTypes
    attribute :statementDate, Types::String.optional
    attribute :isComponent, Types::String.optional
    attribute :entityType, EntityTypes
    attribute :unspecifiedEntityDetails, Types::String.optional
    attribute :name, Types::String.optional
    attribute :alternateNames, Types::String.optional
    attribute :incorporatedInJurisdiction, Types::String.optional
    attribute :identifiers, Types.Array(Identifier).optional
    attribute :foundingDate, Types::String.optional
    attribute :dissolutionDate, Types::String.optional
    attribute :addresses, Types.Array(Address).optional
    attribute :uri, Types::String.optional
    attribute :replacesStatements, Types::String.optional
    attribute :publicationDetails, PublicationDetails.optional
    attribute :source, Source.optional
    attribute :annotations, Types.Array(Annotation)
  end
end
