require 'elasticsearch'
require 'register_sources_bods/repositories/bods_statement_repository'
require 'register_sources_bods/services/es_index_creator'
require 'register_sources_bods/structs/person_statement'
require 'register_sources_bods/structs/entity_statement'
require 'register_sources_bods/structs/ownership_or_control_statement'

RSpec.describe RegisterSourcesBods::Repositories::BodsStatementRepository do
  subject { described_class.new(client: es_client, index: index) }

  let(:index) { SecureRandom.uuid }
  let(:es_client) do
    Elasticsearch::Client.new(
      host: "http://elastic:#{ENV['ELASTICSEARCH_PASSWORD']}@#{ENV['ELASTICSEARCH_HOST']}:#{ENV['ELASTICSEARCH_PORT']}",
      transport_options: { ssl: { verify: false } },
      log: false
    )
  end

  let(:person_statement) do
    RegisterSourcesBods::PersonStatement.new(
      **JSON.parse(
        File.read('spec/fixtures/person_statement.json'),
        symbolize_names: true
      )
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
    index_creator = RegisterSourcesBods::Services::EsIndexCreator.new(
      es_index: index,
      client: es_client
    )
    index_creator.create_es_index
  end

  describe '#store' do
    it 'stores' do
      records = [
        person_statement,
        entity_statement,
        ownership_or_control_statement
      ]

      subject.store(records)

      sleep 1 # eventually consistent, give time

      results = subject.list_all

      expect(results).not_to be_empty
      expect(results.sort_by(&:statementID)).to eq records.sort_by(&:statementID)

      # When records do not exist
      expect(subject.get("missing")).to be_nil
    end
  end

  describe '#list_for_identifier' do
    it 'retrieves by identifier' do
      records = [
        person_statement,
        entity_statement,
        ownership_or_control_statement
      ]

      subject.store(records)

      sleep 1 # eventually consistent, give time

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

      subject.store(records)

      sleep 1 # eventually consistent, give time

      results = subject.list_matching_at_least_one_identifier([person_statement.identifiers.first])
      expect(results).to eq [person_statement]

      results = subject.list_matching_at_least_one_identifier(person_statement.identifiers)
      expect(results).to eq [person_statement]
      
      results = subject.list_matching_at_least_one_identifier(person_statement.identifiers + entity_statement.identifiers)
      expect(results).to eq [person_statement, entity_statement]
    end
  end
end
