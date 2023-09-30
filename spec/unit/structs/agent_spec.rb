# frozen_string_literal: true

require 'register_sources_bods/structs/agent'

RSpec.describe RegisterSourcesBods::Agent do
  subject { described_class }

  context 'when params are valid' do
    let(:params) do
      {
        name: 'residence',
        url: '123 House'
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
