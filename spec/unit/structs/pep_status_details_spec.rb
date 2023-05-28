require 'register_sources_bods/structs/pep_status_details'

RSpec.describe RegisterSourcesBods::PepStatusDetails do
  subject { described_class }

  context 'when params are valid' do
    let(:params) do
      {
        reason: '',
        missingInfoReason: 'no-beneficial-owners',
        jurisdiction: { name: 'France', code: 'FR' },
        startDate: '',
        endDate: '',
        source: {
          type: 'officialRegister',
          description: '',
          url: '',
          retrievedAt: '',
          assertedBy: nil,
        },
      }
    end

    it 'builds struct correctly' do
      expect(subject[params]).to be_a described_class
    end
  end

  context 'when params are invalid' do
    let(:params) do
      { missingInfoReason: 'invalid' }
    end

    it 'raises and error' do
      expect { subject[params] }.to raise_error Dry::Struct::Error
    end
  end
end
