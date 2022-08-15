require 'register_bods_v2/structs/ownership_or_control_statement'

RSpec.describe RegisterBodsV2::OwnershipOrControlStatement do
  subject { described_class }

  context 'when params are valid' do
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
