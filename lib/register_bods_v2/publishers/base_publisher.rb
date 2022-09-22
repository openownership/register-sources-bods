require 'json'
require 'xxhash'

require 'register_bods_v2/repositories/bods_statement_repository'
require 'register_bods_v2/services/records_producer'
require 'register_bods_v2/constants/publisher'

module RegisterBodsV2
  module Publishers
    class BasePublisher
      def initialize(repository: nil, producer: nil)
        @repository = repository || RegisterBodsV2::Repositories::BodsStatementRepository.new(
          client: RegisterBodsV2::Config::ELASTICSEARCH_CLIENT)
        @producer = producer || Services::RecordsProducer.new
      end

      # def publish(record)

      private

      attr_reader :repository, :producer

      def generate_statement_id(attributes)
        XXhash.xxh64(attributes).to_s
      end

      def publish_new_records(records)
        records.each { |record| print record.to_h.to_json, "\n" }

        producer.produce(records)
        producer.finalize

        repository.store(records)
      end
    end
  end
end
