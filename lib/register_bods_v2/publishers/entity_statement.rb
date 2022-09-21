require 'register_bods_v2/publishers/base_publisher'
require 'register_bods_v2/structs/entity_statement'

module RegisterBodsV2
  module Publishers
    class EntityStatement < BasePublisher
      def publish(record)
        unique_attributes = unique_attributes(record)
        statement_id = generate_statement_id(unique_attributes)
  
        existing_record = repository.get(statement_id)

        return existing_record if existing_record # record already exists

        records_for_identifiers = repository.list_matching_at_least_one_identifier(
          record.identifiers)
        
        publication_date = Time.now.utc.to_date.to_s
        new_record =
          RegisterBodsV2::EntityStatement[
            record.to_h.merge(
              statementID: statement_id,
              statementDate: record.statementDate || publication_date,
              replacesStatements: records_for_identifiers.map(&:statementID),
              publicationDetails: RegisterBodsV2::PublicationDetails.new(
                publicationDate: Time.now.utc.to_date.to_s, # TODO: fix publication date
                bodsVersion: RegisterBodsV2::BODS_VERSION,
                license: RegisterBodsV2::BODS_LICENSE,
                publisher: RegisterBodsV2::PUBLISHER
              )
            ).compact
          ]

        publish_new_records([new_record])

        new_record
      end

      def unique_attributes(record)
        attributes = record.to_h
        attributes.reject { |k, _v| [:statementID, :statementDate, :publicationDetails, :source].include? k }
      end
    end
  end
end
