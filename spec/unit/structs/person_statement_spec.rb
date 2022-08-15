require 'register_bods_v2/structs/person_statement'

RSpec.describe RegisterBodsV2::PersonStatement do
  subject { described_class }

  context 'when params are valid' do
    let(:params) do
      {
        statementID: '',
        statementType: 'personStatement',
        statementDate: '',
        isComponent: '',
        personType: 'knownPerson',
        unspecifiedPersonDetails: '',
        names: '',
        identifiers: '',
        nationalities: '',
        placeOfBirth: '',
        birthDate: '',
        deathDate: '',
        placeOfResidence: '',
        taxResidencies: '',
        addresses: '',
        hasPepStatus: '',
        pepStatusDetails: nil,
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
        replacesStatements: ''
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
