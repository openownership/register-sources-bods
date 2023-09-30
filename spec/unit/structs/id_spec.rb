# frozen_string_literal: true

require 'register_sources_bods/structs/id'

RSpec.describe RegisterSourcesBods::Id do
  subject { described_class }

  context 'when params are valid' do
    let(:params) do
      {
        id: ''
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
