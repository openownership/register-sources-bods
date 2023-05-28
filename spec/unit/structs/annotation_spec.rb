require 'register_sources_bods/structs/annotation'

RSpec.describe RegisterSourcesBods::Annotation do
  subject { described_class }

  context 'when params are valid' do
    let(:params) do
      {
        statementPointerTarget: '',
        creationDate: '',
        createdBy: '',
        motivation: 'commenting',
        description: '',
        transformedContent: '',
        url: '',
      }
    end

    it 'builds struct correctly' do
      expect(subject[params]).to be_a described_class
    end
  end

  context 'when params are invalid' do
    let(:params) do
      {
        motivation: 'invalid',
      }
    end

    it 'raises and error' do
      expect { subject[params] }.to raise_error Dry::Struct::Error
    end
  end
end
