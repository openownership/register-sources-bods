require 'register_sources_bods/enums/person_types'

RSpec.describe RegisterSourcesBods::PersonTypes do
  subject { described_class }

  context 'when value is valid' do
    let(:value) { 'knownPerson' }

    it 'accepts value' do
      expect(subject[value]).to eq value
    end
  end

  context 'when value is invalid' do
    let(:value) { 'invalid' }

    it 'raises an error' do
      expect { subject[value] }.to raise_error Dry::Types::ConstraintError
    end
  end
end
