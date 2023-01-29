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
      let(:existing_identifiers) { [] }

      it 'persists record to repository and publishes' do
        mapped_record = subject.build(record, existing_identifiers)

        expect(mapped_record.statementID).to eq statement_id
      end
    end

    context 'when different record for identifiers already exists' do
      let(:existing_identifiers) do
        [
          RegisterSourcesBods::OwnershipOrControlStatement[record.to_h.merge(statementID: 'diffid')]
        ]
      end

      it 'produces new record with a replace statement' do
        mapped_record = subject.build(record, existing_identifiers)

        expect(mapped_record.statementID).to eq statement_id
        expect(mapped_record).not_to eq existing_identifiers[0]
      end
    end

    context 'when same record already exists' do
      let(:existing_identifiers) do
        [
          RegisterSourcesBods::OwnershipOrControlStatement[record.to_h.merge(statementID: statement_id)]
        ]
      end

      it 'returns existing record but does not store or produce record' do
        mapped_record = subject.build(record, existing_identifiers)

        expect(mapped_record.statementID).to eq statement_id
        expect(mapped_record).to eq existing_identifiers[0]
      end
    end
  end
end
