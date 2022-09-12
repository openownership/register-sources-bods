require 'register_bods_v2/structs/bods_statement'

RSpec.describe RegisterBodsV2::BodsStatement do
  subject { described_class }

  context 'when statementType is personStatement' do
    let(:params) do
      {
        statementID: '',
        statementType: 'personStatement',
        statementDate: '',
        isComponent: '',
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
        replacesStatements: ''
      }
    end

    it 'maps statement correctly' do
      expect(subject[params]).to be_a RegisterBodsV2::PersonStatement
    end
  end

  context 'when statementType is entityStatement' do
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

    it 'maps statement correctly' do
      expect(subject[params]).to be_a RegisterBodsV2::EntityStatement
    end
  end

  context 'when statementType is ownershipOrControlStatement' do
    let(:params) do
      {
        statementID: '',
        statementType: 'ownershipOrControlStatement',
        statementDate: '',
        isComponent: '',
        componentStatementIDs: [],
        subject: {
          describedByEntityStatement: '',
        },
        interestedParty: {
          describedByEntityStatement: '',
          describedByPersonStatement: '',
          unspecified: ''
        },
        interests: '',
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
        replacesStatements: '',
      }
    end

    it 'maps statement correctly' do
      expect(subject[params]).to be_a RegisterBodsV2::OwnershipOrControlStatement
    end
  end

  context 'when is unknown type' do
    let(:params) do
      {
        statementType: 'unknown'
      }
    end

    it 'raises and error' do
      expect { subject[params] }.to raise_error RegisterBodsV2::UnknownRecordKindError
    end
  end
end
