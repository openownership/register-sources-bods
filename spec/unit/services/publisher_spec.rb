require 'register_sources_bods/services/publisher'
require 'register_sources_bods/structs/entity_statement'
require 'register_sources_bods/structs/person_statement'
require 'register_sources_bods/structs/ownership_or_control_statement'

RSpec.describe RegisterSourcesBods::Services::Publisher do
  subject do
    described_class.new(
      repository: repository,
      producer: producer,
      builder: builder,
      id_generator: id_generator
    )
  end

  let(:repository) { double 'repository' }
  let(:producer) { double 'producer' }
  let(:builder) { double 'builder' }
  let(:id_generator) { double 'id_generator' }

  let(:statement) do
    RegisterSourcesBods::BodsStatement[
      JSON.parse(
        File.read('spec/fixtures/person_statement.json'),
        symbolize_names: true
      ).compact
    ]
  end

  let(:statement_id) { 'abc1' }

  before do
    expect(repository).to receive(:list_matching_at_least_one_identifier).with(statement.identifiers).and_return []
    allow(id_generator).to receive(:generate_id).with(statement).and_return statement_id
    expect(repository).to receive(:get_bulk).with([statement_id]).and_return []
    expect(builder).to receive(:build).with(statement, []).and_return statement
    expect(producer).to receive(:produce).with([statement])
    expect(producer).to receive(:finalize)
    expect(repository).to receive(:store).with([statement])
  end

  describe '#publish' do
    it 'stores and produces statement' do
      result = subject.publish statement
      expect(result).to eq statement
    end
  end

  describe '#publish_many' do
    it 'stores and produces statements' do
      results = subject.publish_many [statement]
      expect(results).to eq [statement]
    end
  end
end
