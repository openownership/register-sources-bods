# frozen_string_literal: true

require 'register_sources_bods/structs/ownership_or_control_statement'
require 'register_sources_bods/id_generators/ownership_or_control_statement'

RSpec.describe RegisterSourcesBods::IdGenerators::OwnershipOrControlStatement do
  subject { described_class.new }

  describe '#generate_id' do
    let(:record) do
      RegisterSourcesBods::OwnershipOrControlStatement[
        **JSON.parse(
          File.read('spec/fixtures/ownership_or_control_statement.json'),
          symbolize_names: true
        ).compact
      ]
    end

    it 'generates id correctly' do
      statement_id = subject.generate_id record
      expect(statement_id).to eq '7338737691516083850'
    end
  end
end
