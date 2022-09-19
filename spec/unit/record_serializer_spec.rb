require 'json'
require 'register_bods_v2/record_serializer'
require 'register_bods_v2/structs/bods_statement'

RSpec.describe RegisterBodsV2::RecordSerializer do
  subject { described_class.new }

  describe '#serialize' do
    context 'when record is person_statement' do
      let(:person_statement) do
        RegisterBodsV2::BodsStatement[
          JSON.parse(
            File.read('spec/fixtures/person_statement.json'),
            symbolize_names: true
          )
        ]
      end

      it 'serializes correctly' do
        serialized = subject.serialize(person_statement)
        expect(serialized).to be_a String
        expect(RegisterBodsV2::BodsStatement[JSON.parse(serialized)]).to eq person_statement
      end
    end

    context 'when record is entity_statement' do
      let(:entity_statement) do
        RegisterBodsV2::BodsStatement[
          JSON.parse(
            File.read('spec/fixtures/entity_statement.json'),
            symbolize_names: true
          )
        ]
      end

      it 'serializes correctly' do
        serialized = subject.serialize(entity_statement)
        expect(serialized).to be_a String
        expect(RegisterBodsV2::BodsStatement[JSON.parse(serialized)]).to eq entity_statement
      end
    end

    context 'when record is ownership_or_control_statement' do
      let(:ownership_or_control_statement) do
        RegisterBodsV2::BodsStatement[
          JSON.parse(
            File.read('spec/fixtures/ownership_or_control_statement.json'),
            symbolize_names: true
          )
        ]
      end

      it 'serializes correctly' do
        serialized = subject.serialize(ownership_or_control_statement)
        expect(serialized).to be_a String
        expect(RegisterBodsV2::BodsStatement[JSON.parse(serialized)]).to eq ownership_or_control_statement
      end
    end
  end
end
