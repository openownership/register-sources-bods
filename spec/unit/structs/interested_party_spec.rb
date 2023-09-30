# frozen_string_literal: true

require 'register_sources_bods/structs/interested_party'

RSpec.describe RegisterSourcesBods::InterestedParty do
  subject { described_class }

  context 'when params are valid' do
    let(:params) do
      {
        describedByEntityStatement: '',
        describedByPersonStatement: '',
        unspecified: {
          description: 'some description',
          reason: 'no-beneficial-owners'
        }
      }
    end

    it 'builds struct correctly' do
      expect(subject[params]).to be_a described_class
    end
  end

  context 'when params are invalid' do
    let(:params) do
      {
        unspecified: {
          reason: 'invalid'
        }
      }
    end

    it 'raises and error' do
      expect { subject[params] }.to raise_error Dry::Struct::Error
    end
  end
end
