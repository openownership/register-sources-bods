require 'register_bods_v2/repositories/bods_statement_repository'
require 'register_bods_v2/services/records_producer'
  
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
    end
  end
end
