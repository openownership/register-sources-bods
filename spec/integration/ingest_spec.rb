# frozen_string_literal: true

require 'elasticsearch'
require 'register_sources_bods/ingester/app'
require 'register_sources_bods/structs/person_statement'
require 'register_sources_bods/structs/entity_statement'
require 'register_sources_bods/structs/ownership_or_control_statement'

RSpec.describe RegisterSourcesBods::Ingester::App do
  subject { described_class.new(index:, bulk_transformer:) }

  let(:index) { SecureRandom.uuid }

  let(:person_statement) do
    RegisterSourcesBods::PersonStatement.new(
      **JSON.parse(
        File.read('spec/fixtures/person_statement.json'),
        symbolize_names: true
      ).compact
    )
  end

  let(:entity_statement) do
    RegisterSourcesBods::EntityStatement.new(
      **JSON.parse(
        File.read('spec/fixtures/entity_statement.json'),
        symbolize_names: true
      )
    )
  end

  let(:ownership_or_control_statement) do
    RegisterSourcesBods::OwnershipOrControlStatement.new(
      **JSON.parse(
        File.read('spec/fixtures/ownership_or_control_statement.json'),
        symbolize_names: true
      )
    )
  end

  let(:bulk_transformer) { double 'bulk_transformer' }

  before do
    expect(bulk_transformer).to receive(:call).with('s3_prefix').and_yield(
      [
        person_statement.to_h,
        entity_statement.to_h,
        ownership_or_control_statement.to_h,
      ].map(&:to_json)
    )
  end

  describe '#call' do
    it 'calls' do
      subject.call('s3_prefix')
    end
  end
end
