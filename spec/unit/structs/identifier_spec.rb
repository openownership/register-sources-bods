require 'register_bods_v2/structs/identifier'

RSpec.describe RegisterBodsV2::Identifier do
  subject { described_class }

  context 'when params are valid' do
    let(:params) do
      {
        id: '',
        scheme: '',
        schemeName: '',
        uri: ''
      }
    end

    it 'builds struct correctly' do
      expect(subject[params]).to be_a described_class
    end
  end

  context 'when params are invalid' do
    let(:params) do
      { id: nil }
    end

    it 'raises and error' do
      expect { subject[params] }.to raise_error Dry::Struct::Error
    end
  end
end
