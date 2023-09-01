# frozen_string_literal: true

require 'register_sources_oc/repositories/add_id_repository'

require_relative '../mappers/resolver_mappings'
require_relative '../repositories/bods_statement_repository'
require_relative '../services/publisher'

module RegisterSourcesBods
  module Services
    class MigratorLEI
      include RegisterSourcesBods::Mappers::ResolverMappings

      def initialize(
        add_id_repository: RegisterSourcesOc::Repositories::AddIdRepository.new,
        publisher: Services::Publisher.new,
        bods_statement_repository: Repositories::BodsStatementRepository.new
      )
        @publisher = publisher
        @repository_ai = add_id_repository
        @repository_bs = bods_statement_repository
      end

      def migrate(jurisdiction_codes: [], uids: [])
        @repository_ai.each_lei(jurisdiction_codes:, uids:) do |add_id|
          id_lei = identifier_lei_from_add_id(add_id)
          id_oc = identifier_open_corporates_from_company(add_id.jurisdiction_code, add_id.company_number)
          ent_sts = @repository_bs.list_matching_at_least_one_identifier([id_oc], latest: true)
          ent_sts.each do |ent_st|
            next if (ent_st&.identifiers || []).include?(id_lei)

            ent_st.identifiers << id_lei
            @publisher.publish_many({ uid: ent_st })
          end
        end
      end
    end
  end
end
