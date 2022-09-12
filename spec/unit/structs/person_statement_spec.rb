require 'register_bods_v2/structs/person_statement'

RSpec.describe RegisterBodsV2::PersonStatement do
  subject { described_class }

  context 'when params are valid' do
    let(:params) do
      {
        statementID: '',
        statementType: 'personStatement',
        statementDate: '2022-09-07',
        isComponent: false,
        personType: 'knownPerson',
        unspecifiedPersonDetails: {
          description: 'some description',
          reason: 'no-beneficial-owners',
        },
        names: [
          { type: 'individual', fullName: 'Mike', familyName: 'Jones', }
        ],
        identifiers: [
          { id: 'id1' }
        ],
        nationalities: [
          { name: 'France', code: 'FR' }
        ],
        placeOfBirth: { type: 'placeOfBirth', postCode: 'ABC', country: 'FR', address: 'free address field' },
        birthDate: '',
        deathDate: '',
        placeOfResidence: { type: 'placeOfBirth', postCode: 'ABC', country: 'FR', address: 'free address field' },
        taxResidencies: [
          { name: 'France', code: 'FR' }
        ],
        addresses: [
          { type: 'placeOfBirth', postCode: 'ABC', country: 'FR', address: 'free address field' }
        ],
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
        replacesStatements: []
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
