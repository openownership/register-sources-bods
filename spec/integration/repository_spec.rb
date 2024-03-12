# frozen_string_literal: true

require 'elasticsearch'
require 'register_sources_bods/repository'
require 'register_sources_bods/services/es_index_creator'
require 'register_sources_bods/structs/person_statement'
require 'register_sources_bods/structs/entity_statement'
require 'register_sources_bods/structs/ownership_or_control_statement'

RSpec.describe RegisterSourcesBods::Repository do
  subject { described_class.new(client: es_client, index:) }

  let(:index) { "tmp-#{SecureRandom.uuid}" }
  let(:es_client) { Elasticsearch::Client.new }

  let(:person_statement) do
    RegisterSourcesBods::PersonStatement.new(
      **JSON.parse(
        File.read('spec/fixtures/person_statement.json'),
        symbolize_names: true
      ).compact
    )
  end
  let(:person_statement2) do
    RegisterSourcesBods::PersonStatement.new(
      **JSON.parse(
        File.read('spec/fixtures/person_statement2.json'),
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

  before do
    index_creator = RegisterSourcesBods::Services::EsIndexCreator.new(client: es_client)
    index_creator.create_index(index)
  end

  describe '#store' do
    it 'stores' do
      records = [
        person_statement,
        entity_statement,
        ownership_or_control_statement
      ]

      subject.store(records, await_refresh: true)

      results = subject.list_all

      expect(results).not_to be_empty
      expect(results.sort_by(&:statementID)).to eq records.sort_by(&:statementID)

      # When retrieving
      result = subject.get(person_statement.statementID)
      expect(result).to eq person_statement

      # When retrieving many
      result = subject.get_bulk([person_statement, entity_statement].map(&:statementID))
      expect(result.sort_by(&:statementID)).to eq [person_statement, entity_statement].sort_by(&:statementID)

      # When records do not exist
      expect(subject.get('missing')).to be_nil
    end
  end

  describe '#mark_replaced_statements' do
    it 'stores' do
      records = [
        person_statement,
        person_statement2
      ]

      subject.store(records, await_refresh: true)
      subject.mark_replaced_statements(records, await_refresh: true)

      results = es_client.search(
        index:,
        body: {
          query: {
            bool: {
              filter: {
                bool: {
                  should: { match: { 'metadata.replaced': true } }
                }
              }
            }
          }
        }
      )
      results_ids = results['hits']['hits'].map { |r| r['_id'] }
      expect(results_ids).to contain_exactly('ps1')

      results = es_client.search(
        index:,
        body: {
          query: {
            bool: {
              filter: {
                bool: {
                  must_not: {
                    bool: {
                      should: { match: { 'metadata.replaced': true } }
                    }
                  }
                }
              }
            }
          }
        }
      )
      results_ids = results['hits']['hits'].map { |r| r['_id'] }
      expect(results_ids).to contain_exactly('ps2')
    end
  end

  describe '#list_for_identifier' do
    it 'retrieves by identifier' do
      records = [
        person_statement,
        entity_statement,
        ownership_or_control_statement
      ]

      subject.store(records, await_refresh: true)

      # when given single identifier
      results = subject.list_for_identifier(person_statement.identifiers.first)
      expect(results).not_to be_empty
      expect(results).to eq [person_statement]

      # when given single identifier
      results = subject.list_for_identifier(entity_statement.identifiers.first)
      expect(results).not_to be_empty
      expect(results).to eq [entity_statement]
    end
  end

  describe '#list_matching_at_least_one_identifier' do
    it 'retrieves by identifier' do
      records = [
        person_statement,
        entity_statement,
        ownership_or_control_statement
      ]

      subject.store(records, await_refresh: true)

      results = subject.list_matching_at_least_one_identifier([person_statement.identifiers.first])
      expect(results).to eq [person_statement]

      results = subject.list_matching_at_least_one_identifier(person_statement.identifiers)
      expect(results).to eq [person_statement]

      results = subject.list_matching_at_least_one_identifier(
        person_statement.identifiers + entity_statement.identifiers
      )
      expect(results).to eq [entity_statement, person_statement]
    end
  end
end
