require 'register_sources_bods/builders/base'
require 'register_sources_bods/structs/person_statement'
require 'register_sources_bods/constants/publisher'

module RegisterSourcesBods
  module Builders
    class PersonStatement < Base
      REGISTER_SCHEME_NAME = 'OpenOwnership Register'

      def build(record, records_for_identifiers)
        statement_id = generate_statement_id(record)
        old_statement_ids = records_for_identifiers.map(&:statementID)

        return if old_statement_ids.include? statement_id

        first_record = records_for_identifiers.sort_by { |record| record.publicationDetails.publicationDate }.first
        entity_id = first_record ? first_record.statementID : statement_id
        identifiers = record.identifiers + [register_identifier(entity_id)]

        publication_date = Time.now.utc.to_date.to_s

        RegisterSourcesBods::PersonStatement[
          record.to_h.merge(
            statementID: statement_id,
            statementDate: record.statementDate || publication_date,
            identifiers: identifiers,
            replacesStatements: old_statement_ids,
            publicationDetails: RegisterSourcesBods::PublicationDetails.new(
              publicationDate: publication_date,
              bodsVersion: RegisterSourcesBods::BODS_VERSION,
              license: RegisterSourcesBods::BODS_LICENSE,
              publisher: RegisterSourcesBods::PUBLISHER
            )
          ).compact
        ]
      end

      def register_identifier(entity_id)
        url = "/entities/#{entity_id}"

        RegisterSourcesBods::Identifier.new(
          id: url,
          schemeName: REGISTER_SCHEME_NAME,
          uri: url
        )
      end
    end
  end
end
