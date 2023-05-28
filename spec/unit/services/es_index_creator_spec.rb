require 'register_sources_bods/services/es_index_creator'

RSpec.describe RegisterSourcesBods::Services::EsIndexCreator do
  subject { described_class.new(client:, es_index: index) }

  let(:client) { double 'client', indices: double('indices') }
  let(:index) { double 'index' }

  describe '#create_es_index' do
    it 'calls client' do
      expect(client.indices).to receive(:create).with a_hash_including(
        index:,
      )

      subject.create_es_index
    end
  end
end
