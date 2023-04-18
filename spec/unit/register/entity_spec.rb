require 'json'

require 'register_sources_bods/structs/bods_statement'
require 'register_sources_bods/register/entity'

RSpec.describe RegisterSourcesBods::Register::Entity do
  subject { described_class.new(bods_statement) }

  let(:params) { {} }

  let(:bods_statement) { RegisterSourcesBods::BodsStatement[params] }

  context 'when statementType is personStatement' do
    let(:params) do
      JSON.parse(
        File.read('spec/fixtures/person_statement.json'),
        symbolize_names: true
      ).compact
    end

    describe '#address' do
        it 'returns address' do
            expect(subject.address).to eq "free address field"
        end
    end

    describe '#company_number' do
        it 'returns company_number' do
            expect(subject.company_number).to eq nil
        end
    end

    describe '#company_number?' do
        it 'returns true' do
            expect(subject.company_number?).to eq false
        end
    end

    describe '#company_type' do
        it 'returns company_type' do
            expect(subject.company_type).to be_nil
        end
    end

    describe '#country' do
        it 'returns true' do
            expect(subject.country).to eq ISO3166::Country["FR"]
        end
    end

    describe '#country_subdivision' do
        it 'returns country_subdivision' do
            expect(subject.country_subdivision).to be_nil
        end
    end

    describe '#country_of_residence' do
        it 'returns country_of_residence' do
            expect(subject.country_of_residence).to be_nil
        end
    end

    describe '#dissolution_date' do
        it 'returns dissolution_date' do
            expect(subject.dissolution_date).to be_nil
        end
    end

    describe '#dob' do
        it 'returns dob' do
            expect(subject.dob).to eq ISO8601::Date.new("1990-05-03")
        end
    end

    describe '#id' do
        it 'returns id' do
            expect(subject.id).to eq "ps1"
        end
    end

    describe '#identifiers' do
        it 'returns identifiers' do
            expect(subject.identifiers).to eq [
                RegisterSourcesBods::Identifier[{ id: "id2", scheme: "scheme", schemeName: "schemeName" }],
                RegisterSourcesBods::Identifier[{ id: "another-id2", scheme: "scheme2", schemeName: "schemeName2" }]
            ]
        end
    end

    describe '#incorporation_date' do
        it 'returns incorporation_date' do
            expect(subject.incorporation_date).to be_nil
        end
    end

    describe '#incorporation_date?' do
        it 'returns incorporation_date?' do
            expect(subject.incorporation_date?).to eq false
        end
    end

    describe '#jurisdiction_code' do
        it 'returns jurisdiction_code' do
            expect(subject.jurisdiction_code).to be_nil
        end
    end

    describe '#jurisdiction_code?' do
        it 'returns false' do
            expect(subject.jurisdiction_code?).to eq false
        end
    end

    describe '#name' do
        it 'returns name' do
            expect(subject.name).to be_nil
        end
    end

    describe '#natural_person?' do
        it 'returns natural_person?' do
            expect(subject.natural_person?).to eq true
        end
    end

    describe '#self_updated_at' do
        it 'returns self_updated_at' do
            expect(subject.self_updated_at).to eq ''
        end
    end

    describe '#type' do
        it 'returns type' do
            expect(subject.type).to eq "personStatement"
        end
    end

    describe '#unknown_reason' do
        it 'returns unknown_reason' do
            expect(subject.unknown_reason).to be_nil
        end
    end

    describe '#from_denmark_cvr_v2?' do
        it 'returns from_denmark_cvr_v2?' do
            expect(subject.from_denmark_cvr_v2?).to be false
        end
    end

    describe '#merged_entities_count' do
        it 'returns merged_entities_count' do
            expect(subject.merged_entities_count).to eq 0
        end
    end
  end

  context 'when statementType is entityStatement' do
    let(:params) do
      JSON.parse(
        File.read('spec/fixtures/entity_statement.json'),
        symbolize_names: true
      )
    end

    describe '#address' do

    end

    describe '#company_number' do

    end

    describe '#company_number?' do

    end

    describe '#company_type' do

    end

    describe '#country' do

    end

    describe '#country_subdivision' do

    end

    describe '#country_of_residence' do

    end

    describe '#dissolution_date' do

    end

    describe '#dob' do

    end

    describe '#id' do

    end

    describe '#identifiers' do

    end

    describe '#incorporation_date' do

    end

    describe '#incorporation_date?' do

    end

    describe '#jurisdiction_code' do

    end

    describe '#jurisdiction_code?' do

    end

    describe '#name' do

    end

    describe '#natural_person?' do

    end

    describe '#self_updated_at' do

    end

    describe '#type' do

    end

    describe '#unknown_reason' do

    end

    describe '#from_denmark_cvr_v2?' do

    end

    describe '#merged_entities_count' do

    end
  end
end
