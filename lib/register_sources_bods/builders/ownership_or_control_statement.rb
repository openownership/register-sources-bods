# frozen_string_literal: true

require_relative '../constants/publisher'
require_relative '../structs/ownership_or_control_statement'
require_relative 'base'

module RegisterSourcesBods
  module Builders
    class OwnershipOrControlStatement < Base
      def build(record, replaces_ids: []) # rubocop:disable Lint/UnusedMethodArgument # FIXME
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
