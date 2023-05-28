require 'register_sources_bods/publishers/person_statement'

RSpec.describe RegisterSourcesBods::Publishers::PersonStatement do
  subject { described_class.new(repository:, producer:) }

  let(:repository) { double 'repository' }
  let(:producer) { double 'producer' }

  describe '#publish' do
    let(:record) do
      RegisterSourcesBods::PersonStatement[
        **JSON.parse(
          File.read('spec/fixtures/person_statement.json'),
          symbolize_names: true,
        ).compact
      ]
    end

    context 'when record does not already exist' do
      it 'persists record to repository and publishes' do
        expect(repository).to receive(:get).with(
          "18339314454075286224",
        ).and_return nil
        expect(repository).to receive(:list_matching_at_least_one_identifier).with(
          record.identifiers,
        ).and_return []
        allow(repository).to receive(:store)
        allow(producer).to receive(:produce)
        allow(producer).to receive(:finalize)

        mapped_record = subject.publish record

        expect(repository).to have_received(:store).with([mapped_record])
        expect(producer).to have_received(:produce).with([mapped_record])
        expect(producer).to have_received(:finalize)
      end
    end

    context 'when different record for identifiers already exists' do
      it 'produces new record with a replace statement' do
        double 'record'

        expect(repository).to receive(:get).with(
          "18339314454075286224",
        ).and_return nil
        expect(repository).to receive(:list_matching_at_least_one_identifier).with(
          record.identifiers,
        ).and_return [record]
        allow(repository).to receive(:store)
        allow(producer).to receive(:produce)
        allow(producer).to receive(:finalize)

        mapped_record = subject.publish record

        expect(mapped_record.replacesStatements).to eq [record.statementID]
        expect(repository).to have_received(:store).with([mapped_record])
        expect(producer).to have_received(:produce).with([mapped_record])
        expect(producer).to have_received(:finalize)
      end
    end

    context 'when same record already exists' do
      it 'returns existing record but does not store or produce record' do
        existing_record = double 'record'

        expect(repository).to receive(:get).with(
          "18339314454075286224",
        ).and_return existing_record
        expect(repository).not_to receive(:list_matching_at_least_one_identifier)
        expect(repository).not_to receive(:store)
        expect(producer).not_to receive(:produce)
        expect(producer).not_to receive(:finalize)

        mapped_record = subject.publish record

        expect(mapped_record).to eq existing_record
      end
    end
  end
end
