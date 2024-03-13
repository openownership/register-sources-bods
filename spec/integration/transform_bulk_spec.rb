# frozen_string_literal: true

require 'elasticsearch'
require 'register_sources_bods/ingester/ingest_bulk'
require 'register_sources_bods/transformer/transform_bulk'
require 'register_sources_bods/structs/person_statement'
require 'register_sources_bods/structs/entity_statement'
require 'register_sources_bods/structs/ownership_or_control_statement'

RSpec.describe RegisterSourcesBods::Transformer::TransformBulk do
  subject(:transformer) do
    described_class.new(raw_index:, dest_index:, entity_resolver:, bulk_transformer: bulk_transformer_transform)
  end

  let(:es_client) { Elasticsearch::Client.new }
  let(:raw_index) { "tmp-#{SecureRandom.uuid}" }
  let(:dest_index) { "tmp-#{SecureRandom.uuid}" }

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

  let(:bulk_transformer_transform) { instance_double RegisterCommon::Services::BulkTransformer }
  let(:entity_resolver) { instance_double RegisterSourcesOc::Services::ResolverService }

  before do
    bulk_transformer_ingest = instance_double RegisterCommon::Services::BulkTransformer
    ingest_s3_prefix = 'ingest_s3_prefix'

    allow(bulk_transformer_ingest).to receive(:call).with(ingest_s3_prefix).and_yield statements

    allow(entity_resolver).to receive(:resolve)

    RegisterSourcesBods::Ingester::IngestBulk.new(
      index: raw_index,
      bulk_transformer: bulk_transformer_ingest
    ).call(ingest_s3_prefix)
  end

  after do
    es_client.indices.delete(index: raw_index)
    es_client.indices.delete(index: dest_index)
  end

  describe '#call' do
    it 'calls' do
      transform_s3_prefix = 'transform_s3_prefix'

      allow(bulk_transformer_transform).to receive(:call).with(transform_s3_prefix).and_yield statements

      transformer.call(transform_s3_prefix)

      expect(transformer.send(:records_repository).list_all.length).to eq 3
    end
  end
end
