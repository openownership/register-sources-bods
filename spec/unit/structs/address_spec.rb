require 'register_bods_v2/structs/address'

RSpec.describe RegisterBodsV2::Address do
  subject { described_class.new(**fields) }

  let(:fields) do
    {
      type: RegisterBodsV2::AddressTypes['registered'],
      address: "Some address",
      postCode: "CA1 3CD",
      country: "GB"
    }
  end

  it 'creates struct without errors' do
    expect(subject).to be_a RegisterBodsV2::Address
  end
end
