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

      # rubocop:disable Metrics/CyclomaticComplexity
      def migrate(jurisdiction_codes: [], uids: [])
        batch_lei(jurisdiction_codes:, uids:) do |add_ids|
          # construct map of LEI identifiers to OpenCorporates identifiers
          lei_map = add_ids.to_h do |add_id|
            [
              identifier_lei_from_add_id(add_id),
              identifier_open_corporates_from_company(add_id.jurisdiction_code, add_id.company_number)
            ]
          end

          # find existing statements
          ent_sts = @repository_bs.list_matching_at_least_one_identifier(lei_map.values, latest: true)

          # construct new statements
          new_statements = ent_sts.map do |ent_st|
            # filter to get OpenCorporates identifiers
            oc_ids = ent_st.identifiers.filter { |identifier| identifier.schemeName == 'OpenCorporates' }

            # get list of LEI identifiers for these OpenCorporates identifiers
            lei_identifiers = oc_ids.map { |oc_id| lei_map.key(oc_id) }.compact.uniq

            # add any new identifiers
            new_identifiers = lei_identifiers - ent_st.identifiers

            # skip if new identifiers all exist already
            next if new_identifiers.empty?

            # add identifiers to entity statement
            new_identifiers.each { |ident| ent_st.identifiers << ident }

            [ent_st.statementID, ent_st]
          end.compact.to_h

          # skip unless new statements to publish
          next if new_statements.empty?

          # publish any new statements
          @publisher.publish_many(new_statements)
        end
      end
      # rubocop:enable Metrics/CyclomaticComplexity

      def batch_lei(jurisdiction_codes: [], uids: [], chunk_size: 50)
        chunk = []

        @repository_ai.each_lei(jurisdiction_codes:, uids:) do |add_id|
          chunk << add_id

          next if chunk.length < chunk_size

          yield chunk

          chunk = []
        end

        return if chunk.empty?

        yield chunk
      end
    end
  end
end
