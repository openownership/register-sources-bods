require 'json'

require 'register_sources_bods/structs/bods_statement'
require 'register_sources_bods/register/provenance'

RSpec.describe RegisterSourcesBods::Register::Provenance do
  subject { described_class.new(bods_statement) }

  let(:params) { {} }

  let(:bods_statement) { RegisterSourcesBods::BodsStatement[params] }

  context 'when statementType is ownershipOrControlStatement' do
    let(:params) do
      JSON.parse(
        File.read('spec/fixtures/ownership_or_control_statement.json'),
        symbolize_names: true
      ).compact
    end

    describe '#source_url' do
        it 'returns source_url' do
            expect(subject.source_url).to eq "http://download.companieshouse.gov.uk/en_pscdata.html"
        end
    end

    describe '#source_name' do
        it 'returns source_name' do
            expect(subject.source_name).to eq "GB Persons Of Significant Control Register"
        end
    end

    describe '#retrieved_at' do
        it 'returns retrieved_at' do
            expect(subject.retrieved_at).to eq "2023-03-15"
        end
    end

    describe '#imported_at' do
        it 'returns imported_at' do
            expect(subject.imported_at).to eq "2023-03-15"
        end
    end
  end
end
