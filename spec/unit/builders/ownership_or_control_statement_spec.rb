require 'register_sources_bods/builders/ownership_or_control_statement'

RSpec.describe RegisterSourcesBods::Builders::OwnershipOrControlStatement do
  subject { described_class.new(id_generator) }

  let(:id_generator) { double 'id_generator' }

  describe '#build' do
    let(:record) do
      RegisterSourcesBods::OwnershipOrControlStatement[
        **JSON.parse(
          File.read('spec/fixtures/ownership_or_control_statement.json'),
          symbolize_names: true,
        ).compact
      ]
    end

    let(:statement_id) { '12345' }

    before do
      expect(id_generator).to receive(:generate_id).with(record).and_return statement_id
    end

    context 'when record does not already exist' do
      let(:replaces_ids) { [] }

      it 'persists record to repository and publishes' do
        mapped_record = subject.build(record, replaces_ids:)

        expect(mapped_record.statementID).to eq statement_id
        expect(mapped_record.replacesStatements).to be_empty
      end
    end

    context 'when different record for identifiers already exists' do
      let(:replaces_ids) do
        ['diffid']
      end

      it 'produces ignores replaces statements provided' do
        mapped_record = subject.build(record, replaces_ids:)

        expect(mapped_record.statementID).to eq statement_id
        expect(mapped_record.replacesStatements).to be_empty
      end
    end
  end
end
