require 'register_sources_bods/builders/base'
require 'register_sources_bods/structs/entity_statement'
require 'register_sources_bods/constants/publisher'

module RegisterSourcesBods
  module Builders
    class EntityStatement < Base
      REGISTER_SCHEME_NAME = 'OpenOwnership Register'

      def build(record, records_for_identifiers)
        statement_id = generate_statement_id(record)
        
        identifiers = record.identifiers

        register_identifier = identifiers.find { |i| i.schemeName == REGISTER_SCHEME_NAME }
        if !register_identifier
          identifiers << register_identifier(statement_id)
          identifiers = identifiers.sort_by { |i| i.schemeName }
        end

        publication_date = Time.now.utc.to_date.to_s

        RegisterSourcesBods::EntityStatement[
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