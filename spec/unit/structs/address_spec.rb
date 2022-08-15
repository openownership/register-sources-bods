require 'register_bods_v2/structs/address'

RSpec.describe RegisterBodsV2::Address do
  subject { described_class }

  context 'when params are valid' do
    let(:params) do
      {
        type: 'residence',
        address: '123 House',
        postCode: 'ABC 123',
        country: 'United Kingdom'
      }
    end

    it 'builds struct correctly' do
      expect(subject[params]).to be_a described_class
    end
  end

  context 'when params are invalid' do
    let(:params) do
      {
        type: 'invalid',
        address: '123 House',
        postCode: 'ABC 123',
        country: 'United Kingdom'
      }
    end

    it 'raises and error' do
      expect { subject[params] }.to raise_error Dry::Struct::Error
    end
  end
end
