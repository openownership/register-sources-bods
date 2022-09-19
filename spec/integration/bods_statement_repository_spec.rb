require 'elasticsearch'
require 'register_bods_v2/repositories/bods_statement_repository'
require 'register_bods_v2/services/es_index_creator'
require 'register_bods_v2/structs/person_statement'
require 'register_bods_v2/structs/entity_statement'
require 'register_bods_v2/structs/ownership_or_control_statement'

RSpec.describe RegisterBodsV2::Repositories::BodsStatementRepository do
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
    RegisterBodsV2::PersonStatement.new(
      **JSON.parse(
        File.read('spec/fixtures/person_statement.json'),
        symbolize_names: true
      )
    )
  end

  let(:entity_statement) do
    RegisterBodsV2::EntityStatement.new(
      **JSON.parse(
        File.read('spec/fixtures/entity_statement.json'),
        symbolize_names: true
      )
    )
  end

  let(:ownership_or_control_statement) do
    RegisterBodsV2::OwnershipOrControlStatement.new(
      **JSON.parse(
        File.read('spec/fixtures/ownership_or_control_statement.json'),
        symbolize_names: true
      )
    )
  end

  before do
    index_creator = RegisterBodsV2::Services::EsIndexCreator.new(
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
end
