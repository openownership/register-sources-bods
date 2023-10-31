# frozen_string_literal: true

require 'elasticsearch'
require 'register_sources_bods/ingester/app'
require 'register_sources_bods/transformer/transform_bulk'
require 'register_sources_bods/structs/person_statement'
require 'register_sources_bods/structs/entity_statement'
require 'register_sources_bods/structs/ownership_or_control_statement'

RSpec.describe RegisterSourcesBods::Transformer::TransformBulk do
  subject { described_class.new(raw_index:, dest_index:, entity_resolver:, bulk_transformer: bulk_transformer_transform) }

  let(:raw_index) { SecureRandom.uuid }
  let(:dest_index) { SecureRandom.uuid }

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

  let(:bulk_transformer_ingest) { double 'bulk_transformer_ingest' }
  let(:bulk_transformer_transform) { double 'bulk_transformer_transform' }
  let(:ingest_s3_prefix) { 'ingest_s3_prefix' }
  let(:transform_s3_prefix) { 'transform_s3_prefix' }
  let(:entity_resolver) { double 'entity_resolver' }

  before do
    expect(bulk_transformer_ingest).to receive(:call).with(ingest_s3_prefix).and_yield(
      [
        person_statement.to_h,
        entity_statement.to_h,
        ownership_or_control_statement.to_h,
      ].map(&:to_json)
    )

    expect(bulk_transformer_transform).to receive(:call).with(transform_s3_prefix).and_yield(
      [
        person_statement.to_h,
        entity_statement.to_h,
        ownership_or_control_statement.to_h,
      ].map(&:to_json)
    )

    allow(entity_resolver).to receive(:resolve)

    RegisterSourcesBods::Ingester::App.new(
      index: raw_index,
      bulk_transformer: bulk_transformer_ingest
    ).call(ingest_s3_prefix)
  end

  describe '#call' do
    it 'calls' do
      subject.call(transform_s3_prefix)
    end
  end
end
