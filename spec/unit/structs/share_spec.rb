require 'register_bods_v2/structs/share'

RSpec.describe RegisterBodsV2::Share do
  subject { described_class }

  context 'when params are valid' do
    let(:params) do
      {
        exact: '',
        maximum: '',
        minimum: '',
        exclusiveMinimum: '',
        exclusiveMaximum: '',
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
