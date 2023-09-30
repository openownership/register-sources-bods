# frozen_string_literal: true

require 'register_sources_bods/structs/statement_date'

RSpec.describe RegisterSourcesBods::StatementDate do
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
