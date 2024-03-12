# frozen_string_literal: true

require 'elasticsearch'
require 'register_sources_bods/ingester/ingest_bulk'
require 'register_sources_bods/structs/person_statement'
require 'register_sources_bods/structs/entity_statement'
require 'register_sources_bods/structs/ownership_or_control_statement'

RSpec.describe RegisterSourcesBods::Ingester::IngestBulk do
  subject(:transformer) { described_class.new(index:, bulk_transformer:) }

  let(:index) { "tmp-#{SecureRandom.uuid}" }

  let(:statements) do
    [
      RegisterSourcesBods::PersonStatement.new(
        **JSON.parse(
          File.read('spec/fixtures/person_statement_pruned.json'),
          symbolize_names: true
        ).compact
      ),
      RegisterSourcesBods::EntityStatement.new(
        **JSON.parse(
          File.read('spec/fixtures/entity_statement_pruned.json'),
          symbolize_names: true
        )
      ),
      RegisterSourcesBods::OwnershipOrControlStatement.new(
        **JSON.parse(
          File.read('spec/fixtures/ownership_or_control_statement_pruned.json'),
          symbolize_names: true
        )
      )
    ].map(&:to_h).map(&:to_json)
  end

  let(:bulk_transformer) { instance_double RegisterCommon::Services::BulkTransformer }

  before do
    allow(bulk_transformer).to receive(:call).with('s3_prefix').and_yield statements
  end

  describe '#call' do
    it 'calls' do
      transformer.call('s3_prefix')

      expect(transformer.send(:repository).list_all.length).to eq 3
    end
  end
end
