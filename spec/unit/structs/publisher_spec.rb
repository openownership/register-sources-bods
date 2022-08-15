require 'register_bods_v2/structs/publication_details'

RSpec.describe RegisterBodsV2::Publisher do
  subject { described_class }

  context 'when params are valid' do
    let(:params) do
      {
        name: '',
        url: ''
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
