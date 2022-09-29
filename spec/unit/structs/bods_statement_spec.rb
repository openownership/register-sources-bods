require 'json'
require 'register_sources_bods/structs/bods_statement'

RSpec.describe RegisterSourcesBods::BodsStatement do
  subject { described_class }

  context 'when statementType is personStatement' do
    let(:params) do
      JSON.parse(
        File.read('spec/fixtures/person_statement.json'),
        symbolize_names: true
      )
    end

    it 'maps statement correctly' do
      expect(subject[params]).to be_a RegisterSourcesBods::PersonStatement
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
      expect(subject[params]).to be_a RegisterSourcesBods::EntityStatement
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
      expect(subject[params]).to be_a RegisterSourcesBods::OwnershipOrControlStatement
    end
  end

  context 'when is unknown type' do
    let(:params) do
      {
        statementType: 'unknown'
      }
    end

    it 'raises and error' do
      expect { subject[params] }.to raise_error RegisterSourcesBods::UnknownRecordKindError
    end
  end
end
