# frozen_string_literal: true

require 'register_sources_bods/structs/bods_statement'
require 'register_sources_bods/services/migrator_lei'

RSpec.describe RegisterSourcesBods::Services::MigratorLEI do
  subject do
    described_class.new(add_id_repository:, publisher:, bods_statement_repository:)
  end

  let(:add_id_repository) { instance_double(RegisterSourcesOc::Repositories::AddIdRepository) }
  let(:publisher) { instance_double(RegisterSourcesBods::Services::Publisher) }
  let(:bods_statement_repository) { instance_double(RegisterSourcesBods::Repository) }

  let(:ex_oc_identifier) do
    uri = 'https://opencorporates.com/companies/gb/123456'

    RegisterSourcesBods::Identifier[{ id: uri, schemeName: 'OpenCorporates', uri: }]
  end

  let(:missing_oc_identifier) do
    uri = 'https://opencorporates.com/companies/gb/123457'

    RegisterSourcesBods::Identifier[{ id: uri, schemeName: 'OpenCorporates', uri: }]
  end

  let(:statement) do
    st = RegisterSourcesBods::BodsStatement[
      JSON.parse(
        File.read('spec/fixtures/person_statement.json'),
        symbolize_names: true
      ).compact
    ]

    st.identifiers << ex_oc_identifier

    st
  end

  let(:ex_add_id) do
    RegisterSourcesOc::AddId[{
      company_number: '123456',
      jurisdiction_code: 'gb',
      uid: 'uid1',
      identifier_system_code: 'XI-LEI'
    }]
  end

  let(:missing_add_id) do
    RegisterSourcesOc::AddId[{
      company_number: '123457',
      jurisdiction_code: 'gb',
      uid: 'uid2',
      identifier_system_code: 'XI-LEI'
    }]
  end

  let(:ex_statements) { [statement] }

  let(:new_statements) do
    st = RegisterSourcesBods::BodsStatement[
      JSON.parse(
        File.read('spec/fixtures/person_statement.json'),
        symbolize_names: true
      ).compact
    ]

    st.identifiers << ex_oc_identifier
    st.identifiers << RegisterSourcesBods::Identifier[{
      id: 'uid1',
      scheme: 'XI-LEI',
      schemeName: 'Global Legal Entity Identifier Index',
      uri: 'https://search.gleif.org/#/record/uid1'
    }]

    [st]
  end

  describe '#migrate' do
    it 'migrates and publishes statements' do
      expect(add_id_repository).to receive(:each_lei).with(jurisdiction_codes: [], uids: [])
                                                     .and_yield(ex_add_id)
                                                     .and_yield(missing_add_id)

      allow(bods_statement_repository).to receive(:list_matching_at_least_one_identifier).with(
        [ex_oc_identifier, missing_oc_identifier],
        { latest: true }
      ).and_return ex_statements

      expect(publisher).to receive(:publish_many).with(
        { ex_statements[0].statementID => ex_statements[0] }
      )

      subject.migrate
    end
  end
end
