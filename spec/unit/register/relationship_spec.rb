require 'json'

require 'register_sources_bods/structs/bods_statement'
require 'register_sources_bods/register/relationship'

RSpec.describe RegisterSourcesBods::Register::Relationship do
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

    describe '#_id' do
        it 'returns _id' do
            expect(subject._id).to eq "ocs1"
        end
    end

    describe '#ended_date' do
        it 'returns ended_date' do
            expect(subject.ended_date).to eq "2017-03-30"
        end
    end

    describe '#id' do
        it 'returns id' do
            expect(subject.id).to eq "ocs1"
        end
    end

    describe '#interests' do
        it 'returns interests' do
            expect(subject.interests).to eq [
              RegisterSourcesBods::Interest[{
                type: "shareholding",
                interestLevel: nil,
                beneficialOwnershipOrControl: nil,
                details: "ownership-of-shares-25-to-50-percent",
                share: RegisterSourcesBods::Share[{
                  maximum: 50.0,
                  minimum: 25.0,
                  exclusiveMinimum: true,
                  exclusiveMaximum: false
                }],
                startDate: "2016-07-27",
                endDate: "2017-03-30"
              }.compact]
            ]
        end
    end

    describe '#is_indirect' do
        it 'returns is_indirect' do
            expect(subject.is_indirect).to eq false
        end
    end

    describe '#keys_for_uniq_grouping' do
        it 'returns keys_for_uniq_grouping' do
            expect(subject.keys_for_uniq_grouping).to eq ["shareholding"]
        end
    end

    describe '#sample_date' do
        it 'returns sample_date' do
            expect(subject.sample_date).to eq "2016-07-27"
        end
    end

    describe '#started_date' do
        it 'returns started_date' do
            expect(subject.started_date).to eq "2016-07-27"
        end
    end

    describe '#source_id' do
        it 'returns source_id' do
            expect(subject.source_id).to eq nil
        end
    end

    describe '#target_id' do
        it 'returns target_id' do
            expect(subject.target_id).to eq nil
        end
    end
  end
end
