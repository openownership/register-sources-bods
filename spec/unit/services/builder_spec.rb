require 'register_sources_bods/services/builder'
require 'register_sources_bods/structs/entity_statement'
require 'register_sources_bods/structs/person_statement'
require 'register_sources_bods/structs/ownership_or_control_statement'

RSpec.describe RegisterSourcesBods::Services::Builder do
  subject do
    described_class.new(
      entity_statement_builder: entity_statement_builder,
      person_statement_builder: person_statement_builder,
      ownership_or_control_statement_builder: ownership_or_control_statement_builder
    )
  end

  let(:entity_statement_builder) { double 'entity_statement_builder' }
  let(:person_statement_builder) { double 'person_statement_builder' }
  let(:ownership_or_control_statement_builder) { double 'ownership_or_control_statement_builder' }

  describe '#build' do
    let(:statement) { double 'statement', statementType: statement_type }
    let(:replaces_ids) { double 'replaces_ids' }

    context 'when record is person statement' do
      let(:statement_type) { RegisterSourcesBods::StatementTypes['personStatement'] }

      it 'calls person_statement_builder with statement' do
        expect(person_statement_builder).to receive(:build).with(statement, replaces_ids: replaces_ids)

        subject.build(statement, replaces_ids: replaces_ids)
      end
    end

    context 'when record is entity statement' do
      let(:statement_type) { RegisterSourcesBods::StatementTypes['entityStatement'] }

      it 'calls entity_statement_builder with statement' do
        expect(entity_statement_builder).to receive(:build).with(statement, replaces_ids: replaces_ids)

        subject.build(statement, replaces_ids: replaces_ids)
      end
    end

    context 'when record is ownership or control statement' do
      let(:statement_type) { RegisterSourcesBods::StatementTypes['ownershipOrControlStatement'] }

      it 'calls ownership_or_control_statement_builder with statement' do
        expect(ownership_or_control_statement_builder).to receive(:build).with(statement, replaces_ids: replaces_ids)

        subject.build(statement, replaces_ids: replaces_ids)
      end
    end

    context 'when record has invalid type' do
      let(:statement_type) { 'invalid' }

      it 'raises an error' do
        expect { subject.build(statement, replaces_ids: replaces_ids) }.to raise_error RegisterSourcesBods::Errors::UnknownRecordKindError
      end
    end
  end
end
