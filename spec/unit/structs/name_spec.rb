require 'register_bods_v2/structs/name'

RSpec.describe RegisterBodsV2::Name do
  subject { described_class }

  context 'when params are valid' do
    let(:params) do
      {
        type: '',
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
      {}
    end

    it 'raises and error' do
      expect { subject[params] }.to raise_error Dry::Struct::Error
    end
  end
end
