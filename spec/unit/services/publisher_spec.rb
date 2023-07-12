require 'register_sources_bods/services/publisher'
require 'register_sources_bods/structs/entity_statement'
require 'register_sources_bods/structs/person_statement'
require 'register_sources_bods/structs/ownership_or_control_statement'

RSpec.describe RegisterSourcesBods::Services::Publisher do
  subject do
    described_class.new(
      repository:,
      producer:,
      builder:,
      pending_records_builder:,
    )
  end

  let(:repository) { double 'repository' }
  let(:producer) { double 'producer' }
  let(:builder) { double 'builder' }
  let(:pending_records_builder) { double 'pending_records_builder' }

  let(:statement) do
    RegisterSourcesBods::BodsStatement[
      JSON.parse(
        File.read('spec/fixtures/person_statement.json'),
        symbolize_names: true,
      ).compact
    ]
  end

  before do
    expect(producer).to receive(:produce).with([statement])
    expect(producer).to receive(:finalize)
    expect(repository).to receive(:get_bulk).with([statement.statementID]).and_return []
    expect(repository).to receive(:store).with([statement])
    expect(pending_records_builder).to receive(:build_all).with(
      { statement_uuid => statement },
    ).and_return(
      [
        {
          new_records: [statement],
          unreplaced_statements: [statement],
          uids: [statement_uuid],
        },
      ],
    )
  end

  describe '#publish' do
    let(:statement_uuid) { :uid }

    it 'stores and produces statement' do
      result = subject.publish statement
      expect(result).to eq statement
    end
  end

  describe '#publish_many' do
    let(:statement_uuid) { 'uid123' }

    it 'stores and produces statements' do
      statements = { statement_uuid => statement }

      results = subject.publish_many(statements)
      expect(results).to eq statements
    end
  end
end
