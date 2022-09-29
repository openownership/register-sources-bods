require 'register_sources_bods/structs/name'

RSpec.describe RegisterSourcesBods::Name do
  subject { described_class }

  context 'when params are valid' do
    let(:params) do
      {
        type: 'individual',
        fullName: '',
        familyName: '',
        givenName: '',
        patronymicName: '',
      }
    end

    it 'builds struct correctly' do
      expect(subject[params]).to be_a described_class
    end
  end

  context 'when params are invalid' do
    let(:params) do
      { type: 'invalid' }
    end

    it 'raises and error' do
      expect { subject[params] }.to raise_error Dry::Struct::Error
    end
  end
end
