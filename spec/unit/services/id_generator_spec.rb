# frozen_string_literal: true

require 'register_sources_bods/services/id_generator'
require 'register_sources_bods/structs/entity_statement'
require 'register_sources_bods/structs/person_statement'
require 'register_sources_bods/structs/ownership_or_control_statement'

RSpec.describe RegisterSourcesBods::Services::IdGenerator do
  subject do
    described_class.new(
      entity_statement_id_generator:,
      person_statement_id_generator:,
      ownership_or_control_statement_id_generator:
    )
  end

  let(:entity_statement_id_generator) { double 'entity_statement_id_generator' }
  let(:person_statement_id_generator) { double 'person_statement_id_generator' }
  let(:ownership_or_control_statement_id_generator) { double 'ownership_or_control_statement_id_generator' }

  describe '#generate_id' do
    let(:statement) { double 'statement', statementType: statement_type }

    context 'when record is person statement' do
      let(:statement_type) { RegisterSourcesBods::StatementTypes['personStatement'] }

      it 'calls person_statement_id_generator with statement' do
        expect(person_statement_id_generator).to receive(:generate_id).with(statement)

        subject.generate_id statement
      end
    end

    context 'when record is entity statement' do
      let(:statement_type) { RegisterSourcesBods::StatementTypes['entityStatement'] }

      it 'calls entity_statement_id_generator with statement' do
        expect(entity_statement_id_generator).to receive(:generate_id).with(statement)

        subject.generate_id statement
      end
    end

    context 'when record is ownership or control statement' do
      let(:statement_type) { RegisterSourcesBods::StatementTypes['ownershipOrControlStatement'] }

      it 'calls ownership_or_control_statement_id_generator with statement' do
        expect(ownership_or_control_statement_id_generator).to receive(:generate_id).with(statement)

        subject.generate_id statement
      end
    end

    context 'when record has invalid type' do
      let(:statement_type) { 'invalid' }

      it 'raises an error' do
        expect { subject.generate_id statement }.to raise_error RegisterSourcesBods::Errors::UnknownRecordKindError
      end
    end
  end
end
