require 'register_sources_bods/structs/publication_details'

RSpec.describe RegisterSourcesBods::PublicationDetails do
  subject { described_class }

  context 'when params are valid' do
    let(:params) do
      {
        publicationDate: '',
        bodsVersion: '',
        license: '',
        publisher: {
          name: '',
          url: '',
        },
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
