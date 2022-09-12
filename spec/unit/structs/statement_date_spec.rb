require 'register_bods_v2/structs/statement_date'

RSpec.describe RegisterBodsV2::StatementDate do
  subject { described_class }

  context 'when params are valid' do
    let(:params) { '' }

    it 'builds struct correctly' do
      expect { subject[params] }.not_to raise_error
    end
  end

  context 'when params are invalid' do
    let(:params) { nil }

    it 'raises and error' do
      expect { subject[params] }.to raise_error Dry::Types::ConstraintError
    end
  end
end
