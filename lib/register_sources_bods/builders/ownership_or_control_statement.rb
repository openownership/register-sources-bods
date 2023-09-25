# frozen_string_literal: true

require 'register_sources_bods/builders/base'
require 'register_sources_bods/structs/ownership_or_control_statement'
require 'register_sources_bods/constants/publisher'

module RegisterSourcesBods
  module Builders
    class OwnershipOrControlStatement < Base
      def build(record, replaces_ids: [])
        statement_id = generate_statement_id(record)

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
