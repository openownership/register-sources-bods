require 'register_bods_v2/structs/entity_statement'

RSpec.describe RegisterBodsV2::EntityStatement do
  subject { described_class }

  context 'when params are valid' do
    let(:params) do
      {
        statementID: '',
        statementType: 'entityStatement',
        statementDate: '',
        isComponent: '',
        entityType: 'legalEntity',
        unspecifiedEntityDetails: '',
        name: '',
        alternateNames: '',
        incorporatedInJurisdiction: '',
        identifiers: [],
        foundingDate: '',
        dissolutionDate: '',
        addresses: [],
        uri: '',
        replacesStatements: '',
        publicationDetails: {
          publicationDate: '',
          bodsVersion: '',
          license: '',
          publisher: {
            name: '',
            url: ''
          }
        },
        source: {
          type: 'officialRegister',
          description: '',
          url: '',
          retrievedAt: '',
          assertedBy: nil,
        },
        annotations: [],
      }
    end

    it 'builds struct correctly' do
      expect(subject[params]).to be_a described_class
    end
  end

  context 'when params are invalid' do
    let(:params) do
      {}
    end

    it 'raises and error' do
      expect { subject[params] }.to raise_error Dry::Struct::Error
    end
  end
end
