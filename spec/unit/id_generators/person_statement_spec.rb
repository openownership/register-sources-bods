require 'register_sources_bods/structs/person_statement'
require 'register_sources_bods/id_generators/person_statement'

RSpec.describe RegisterSourcesBods::IdGenerators::PersonStatement do
  subject { described_class.new }

  describe '#generate_id' do
    let(:record) do
      RegisterSourcesBods::PersonStatement[
        **JSON.parse(
          File.read('spec/fixtures/person_statement.json'),
          symbolize_names: true
        ).compact
      ]
    end

    it 'generates id correctly' do
      statement_id = subject.generate_id record
      expect(statement_id).to eq "9883722852789572130"
    end
  end
end
