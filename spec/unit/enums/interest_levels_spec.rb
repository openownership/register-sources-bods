require 'register_bods_v2/enums/interest_levels'

RSpec.describe RegisterBodsV2::InterestLevels do
  subject { described_class }

  context 'when value is valid' do
    let(:value) { 'direct' }

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
