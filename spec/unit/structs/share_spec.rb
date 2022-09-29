require 'register_sources_bods/structs/share'

RSpec.describe RegisterSourcesBods::Share do
  subject { described_class }

  context 'when params are valid' do
    let(:params) do
      {
        exact: 53.3,
        maximum: 60.2,
        minimum: 29.5,
        exclusiveMinimum: false,
        exclusiveMaximum: false,
      }
    end

    it 'builds struct correctly' do
      expect(subject[params]).to be_a described_class
    end
  end

  context 'when params are invalid' do
    let(:params) do
      { exact: 'invalid' }
    end

    it 'raises and error' do
      expect { subject[params] }.to raise_error Dry::Struct::Error
    end
  end
end
