# frozen_string_literal: true

require 'register_sources_bods/structs/interest'

RSpec.describe RegisterSourcesBods::Interest do
  subject { described_class }

  context 'when params are valid' do
    let(:params) do
      {
        type: 'shareholding',
        interestLevel: 'direct',
        beneficialOwnershipOrControl: false,
        details: '',
        share: {
          exact: 53.3,
          maximum: 60.2,
          minimum: 29.5,
          exclusiveMinimum: false,
          exclusiveMaximum: false
        },
        startDate: '2022-03-01',
        endDate: '2022-05-09'
      }
    end

    it 'builds struct correctly' do
      expect(subject[params]).to be_a described_class
    end
  end

  context 'when params are invalid' do
    let(:params) do
      { type: 'something' }
    end

    it 'raises and error' do
      expect { subject[params] }.to raise_error Dry::Struct::Error
    end
  end
end
