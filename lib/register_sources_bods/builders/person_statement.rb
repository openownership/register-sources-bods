require 'register_sources_bods/builders/base'
require 'register_sources_bods/structs/person_statement'
require 'register_sources_bods/constants/identifiers'
require 'register_sources_bods/constants/publisher'

module RegisterSourcesBods
  module Builders
    class PersonStatement < Base
      def build(record, replaces_ids: [])
        statement_id = generate_statement_id(record)

        identifiers = record.identifiers.to_a

        register_identifier = identifiers.find { |i| i.schemeName == REGISTER_SCHEME_NAME }
        if !register_identifier
          identifiers << register_identifier(statement_id)
        end

        identifiers = identifiers.sort_by { |i| i.schemeName || i.scheme }

        publication_date = Time.now.utc.to_date.to_s

        RegisterSourcesBods::PersonStatement[
          record.to_h.merge(
            statementID: statement_id,
            statementDate: record.statementDate || publication_date,
            identifiers: identifiers,
            replacesStatements: replaces_ids,
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
