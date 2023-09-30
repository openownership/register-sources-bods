# frozen_string_literal: true

require 'register_sources_bods/structs/entity_statement'
require 'register_sources_bods/id_generators/entity_statement'

RSpec.describe RegisterSourcesBods::IdGenerators::EntityStatement do
  subject { described_class.new }

  describe '#generate_id' do
    let(:record) do
      RegisterSourcesBods::EntityStatement[
        **JSON.parse(
          File.read('spec/fixtures/entity_statement.json'),
          symbolize_names: true
        ).compact
      ]
    end

    it 'generates id correctly' do
      statement_id = subject.generate_id record
      expect(statement_id).to eq '6211640141168649862'
    end
  end
end
