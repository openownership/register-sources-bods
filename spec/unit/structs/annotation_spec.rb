require 'register_bods_v2/structs/annotation'

RSpec.describe RegisterBodsV2::Annotation do
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
        url: ''
      }
    end

    it 'builds struct correctly' do
      expect(subject[params]).to be_a described_class
    end
  end

  context 'when params are invalid' do
    let(:params) do
      {
        motivation: 'invalid'
      }
    end

    it 'raises and error' do
      expect { subject[params] }.to raise_error Dry::Struct::Error
    end
  end
end
