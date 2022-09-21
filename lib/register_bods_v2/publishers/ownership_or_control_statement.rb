require 'register_bods_v2/publishers/base_publisher'
require 'register_bods_v2/structs/ownership_or_control_statement'

module RegisterBodsV2
  module Publishers
    class OwnershipOrControlStatement < BasePublisher
      def publish(record)
        unique_attributes = unique_attributes(record)
        statement_id = generate_statement_id(unique_attributes)
  
        existing_record = repository.get(statement_id)

        return existing_record if existing_record # record already exists

        new_record =
          RegisterBodsV2::OwnershipOrControlStatement[
            record.to_h.merge(
              statementID: statement_id,
              publicationDetails: RegisterBodsV2::PublicationDetails.new(
                publicationDate: Time.now.utc.to_date.to_s,
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
        attributes.reject { |k, _v| [:statementID, :publicationDetails, :source].include? k }
      end
    end
  end
end
