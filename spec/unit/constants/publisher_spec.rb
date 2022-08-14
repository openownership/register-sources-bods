require 'register_bods_v2/constants/publisher'

RSpec.describe RegisterBodsV2 do
  subject { described_class }

  it 'has publisher constants defined' do
    expect(described_class.const_defined?(:BODS_VERSION)).to be true
    expect(described_class.const_defined?(:BODS_LICENSE)).to be true
    expect(described_class::PUBLISHER).to be_a RegisterBodsV2::Publisher
  end
end
