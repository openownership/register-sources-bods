require 'register_sources_bods/builders/base'
require 'register_sources_bods/structs/ownership_or_control_statement'
require 'register_sources_bods/constants/publisher'

module RegisterSourcesBods
  module Builders
    class OwnershipOrControlStatement < Base
      def build(record, records_for_identifiers)
        statement_id = generate_statement_id(record)

        existing_statement = records_for_identifiers.find { |record| record.statementID == statement_id }

        return existing_statement if existing_statement

        RegisterSourcesBods::OwnershipOrControlStatement[
          record.to_h.merge(
            statementID: statement_id,
            publicationDetails: RegisterSourcesBods::PublicationDetails.new(
              publicationDate: Time.now.utc.to_date.to_s,
              bodsVersion: RegisterSourcesBods::BODS_VERSION,
              license: RegisterSourcesBods::BODS_LICENSE,
              publisher: RegisterSourcesBods::PUBLISHER
            )
          ).compact
        ]
      end
    end
  end
end
