# frozen_string_literal: true

require_relative '../constants/identifiers'
require_relative '../constants/publisher'
require_relative '../structs/entity_statement'
require_relative 'base'

module RegisterSourcesBods
  module Builders
    class EntityStatement < Base
      def build(record, replaces_ids: [])
        statement_id = generate_statement_id(record)

        identifiers = record.identifiers.to_a

        register_identifier = identifiers.find { |i| i.schemeName == IDENTIFIER_NAME_REG }
        identifiers << register_identifier(statement_id) unless register_identifier

        identifiers = identifiers.sort_by { |i| i.schemeName || i.scheme }

        publication_date = Time.now.utc.to_date.to_s

        RegisterSourcesBods::EntityStatement[
          record.to_h.merge(
            statementID: statement_id,
            statementDate: record.statementDate || publication_date,
            identifiers:,
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
          schemeName: IDENTIFIER_NAME_REG,
          uri: url
        )
      end
    end
  end
end
