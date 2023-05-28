require 'register_sources_bods/services/publisher'
require 'register_sources_bods/structs/entity_statement'
require 'register_sources_bods/structs/person_statement'
require 'register_sources_bods/structs/ownership_or_control_statement'

RSpec.describe RegisterSourcesBods::Services::Publisher do
  subject do
    described_class.new(
      entity_statement_publisher:,
      person_statement_publisher:,
      ownership_or_control_statement_publisher:,
    )
  end

  let(:entity_statement_publisher) { double 'entity_statement_publisher' }
  let(:person_statement_publisher) { double 'person_statement_publisher' }
  let(:ownership_or_control_statement_publisher) { double 'ownership_or_control_statement_publisher' }

  describe '#publish' do
    context 'when record is person statement' do
      let(:statement) do
        RegisterSourcesBods::BodsStatement[
          JSON.parse(
            File.read('spec/fixtures/person_statement.json'),
            symbolize_names: true,
          )
        ]
      end

      it 'calls person_statement_publisher with statement' do
        expect(person_statement_publisher).to receive(:publish).with(statement)

        subject.publish statement
      end
    end

    context 'when record is entity statement' do
      let(:statement) do
        RegisterSourcesBods::BodsStatement[
          JSON.parse(
            File.read('spec/fixtures/entity_statement.json'),
            symbolize_names: true,
          )
        ]
      end

      it 'calls entity_statement_publisher with statement' do
        expect(entity_statement_publisher).to receive(:publish).with(statement)

        subject.publish statement
      end
    end

    context 'when record is ownership or control statement' do
      let(:statement) do
        RegisterSourcesBods::BodsStatement[
          JSON.parse(
            File.read('spec/fixtures/ownership_or_control_statement.json'),
            symbolize_names: true,
          )
        ]
      end

      it 'calls ownership_or_control_statement_publisher with statement' do
        expect(ownership_or_control_statement_publisher).to receive(:publish).with(statement)

        subject.publish statement
      end
    end

    context 'when record is not valid bods statement' do
      context 'with valid type but invalid other params' do
        let(:statement) { { statementType: 'personStatement' } }

        it 'raises an error' do
          expect { subject.publish statement }.to raise_error RegisterSourcesBods::UnknownRecordKindError
        end
      end

      context 'with invalid type' do
        let(:statement) { { statementType: 'invalid' } }

        it 'raises an error' do
          expect { subject.publish statement }.to raise_error RegisterSourcesBods::UnknownRecordKindError
        end
      end
    end
  end
end
