require 'json'
require 'register_bods_v2/structs/bods_statement'

RSpec.describe RegisterBodsV2::BodsStatement do
  subject { described_class }

  context 'when statementType is personStatement' do
    let(:params) do
      JSON.parse(
        File.read('spec/fixtures/person_statement.json'),
        symbolize_names: true
      )
    end

    it 'maps statement correctly' do
      expect(subject[params]).to be_a RegisterBodsV2::PersonStatement
    end
  end

  context 'when statementType is entityStatement' do
    let(:params) do
      JSON.parse(
        File.read('spec/fixtures/entity_statement.json'),
        symbolize_names: true
      )
    end

    it 'maps statement correctly' do
      expect(subject[params]).to be_a RegisterBodsV2::EntityStatement
    end
  end

  context 'when statementType is ownershipOrControlStatement' do
    let(:params) do
      JSON.parse(
        File.read('spec/fixtures/ownership_or_control_statement.json'),
        symbolize_names: true
      )
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
