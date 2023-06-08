require 'register_sources_bods/structs/entity_statement'
require 'register_sources_bods/structs/person_statement'
require 'register_sources_bods/structs/ownership_or_control_statement'
require 'register_sources_bods/services/pending_records'

RSpec.describe RegisterSourcesBods::Services::PendingRecords do
  subject do
    described_class.new(repository:, builder:)
  end

  let(:repository) { double 'repository' }
  let(:builder) { double 'builder' }

  let(:statement) do
    RegisterSourcesBods::BodsStatement[
      JSON.parse(
        File.read('spec/fixtures/person_statement.json'),
        symbolize_names: true,
      ).compact
    ]
  end

  let(:statement_id) { 'abc1' }

  describe '#build_all' do
    context 'when statements are empty' do
      let(:statements) { [] }

      it 'builds statements' do
        expect(subject.build_all(statements)).to eq []
      end
    end

    context 'when statements are not-empty' do
      before do
        expect(repository).to receive(:list_matching_at_least_one_identifier).with(statement.identifiers).and_return []
        expect(builder).to receive(:build).with(statement, replaces_ids: []).and_return statement
      end

      let(:statements) { [statement] }

      it 'builds statements' do
        expect(subject.build_all(statements)).to eq []
      end
    end
    
  end
end
