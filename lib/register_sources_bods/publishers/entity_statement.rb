require 'register_sources_bods/publishers/base_publisher'
require 'register_sources_bods/structs/entity_statement'

module RegisterSourcesBods
  module Publishers
    class EntityStatement < BasePublisher
      REGISTER_SCHEME_NAME = 'OpenOwnership Register'.freeze

      def publish(record)
        unique_attributes = unique_attributes(record)
        statement_id = generate_statement_id(unique_attributes)

        existing_record = repository.get(statement_id)

        return existing_record if existing_record # record already exists

        records_for_identifiers = repository.list_matching_at_least_one_identifier(
          record.identifiers,
        )

        # TODO: merging records from different sources
        first_record = records_for_identifiers.min_by { |record| record.publicationDetails.publicationDate }
        entity_id = first_record ? first_record.statementID : statement_id
        identifiers = record.identifiers + [register_identifier(entity_id)]

        publication_date = Time.now.utc.to_date.to_s
        new_record =
          RegisterSourcesBods::EntityStatement[
            record.to_h.merge(
              statementID: statement_id,
              statementDate: record.statementDate || publication_date,
              identifiers:,
              replacesStatements: records_for_identifiers.map(&:statementID),
              publicationDetails: RegisterSourcesBods::PublicationDetails.new(
                publicationDate: publication_date,
                bodsVersion: RegisterSourcesBods::BODS_VERSION,
                license: RegisterSourcesBods::BODS_LICENSE,
                publisher: RegisterSourcesBods::PUBLISHER,
              ),
            ).compact
          ]

        publish_new_records([new_record])

        new_record
      end

      def unique_attributes(record)
        attributes = record.to_h
        attributes.except(:statementID, :statementDate, :publicationDetails, :source)
      end

      def register_identifier(entity_id)
        url = "/entities/#{entity_id}"

        RegisterSourcesBods::Identifier.new(
          id: url,
          schemeName: REGISTER_SCHEME_NAME,
          uri: url,
        )
      end
    end
  end
end
