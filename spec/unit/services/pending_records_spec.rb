# frozen_string_literal: true

require 'register_sources_bods/structs/entity_statement'
require 'register_sources_bods/structs/person_statement'
require 'register_sources_bods/structs/ownership_or_control_statement'
require 'register_sources_bods/services/pending_records'

RSpec.describe RegisterSourcesBods::Services::PendingRecords do
  subject do
    described_class.new(repository:, builder:)
  end

  let(:repository) { instance_double(RegisterSourcesBods::Repository) }
  let(:builder) { instance_double(RegisterSourcesBods::Services::Builder) }

  let(:statement) do
    RegisterSourcesBods::BodsStatement[
      JSON.parse(
        File.read('spec/fixtures/person_statement.json'),
        symbolize_names: true
      ).compact
    ]
  end

  let(:statement_id) { 'abc1' }

  describe '#build_all' do
    context 'when statements are empty' do
      let(:statements) { {} }

      it 'builds statements' do
        expect(subject.build_all(statements)).to eq []
      end
    end

    context 'when statements are not-empty' do
      before do
        allow(repository).to receive(:list_matching_at_least_one_identifier).with(statement.identifiers).and_return []
        allow(repository).to receive(:list_matching_at_least_one_source).with([]).and_return []
        allow(builder).to receive(:build).with(statement, replaces_ids: []).and_return statement
      end

      let(:statements) { { uid: statement } }

      it 'builds statements' do
        expect(subject.build_all(statements)).to eq [
          {
            new_records: [statement],
            uids: [:uid],
            unreplaced_statements: [statement]
          }
        ]
      end
    end
  end
end
