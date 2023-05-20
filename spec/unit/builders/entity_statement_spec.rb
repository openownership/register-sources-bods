require 'register_sources_bods/builders/entity_statement'

RSpec.describe RegisterSourcesBods::Builders::EntityStatement do
  subject { described_class.new(id_generator) }

  let(:id_generator) { double 'id_generator' }

  describe '#build' do
    let(:record) do
      RegisterSourcesBods::EntityStatement[
        **JSON.parse(
          File.read('spec/fixtures/entity_statement.json'),
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
        mapped_record = subject.build(record, replaces_ids: replaces_ids)

        expect(mapped_record.statementID).to eq statement_id
        expect(mapped_record.replacesStatements).to be_empty
      end
    end

    context 'when different record for identifiers already exists' do
      let(:replaces_ids) { ['diffid'] }

      it 'produces new record with a replace statement' do
        mapped_record = subject.build(record, replaces_ids: replaces_ids)

        expect(mapped_record.statementID).to eq statement_id
        expect(mapped_record.replacesStatements).to eq replaces_ids
      end
    end
  end
end
