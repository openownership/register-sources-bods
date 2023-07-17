require 'register_sources_bods/constants/publisher'

RSpec.describe RegisterSourcesBods do
  subject { described_class }

  it 'has publisher constants defined' do
    expect(described_class.const_defined?(:BODS_VERSION)).to be true
    expect(described_class.const_defined?(:BODS_LICENSE)).to be true
    expect(described_class::PUBLISHER).to be_a RegisterSourcesBods::Publisher
  end
end
