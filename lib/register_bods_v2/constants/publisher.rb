require 'register_bods_v2/structs/publisher'

module RegisterBodsV2
  BODS_VERSION = "0.2"
  BODS_LICENSE = "https://register.openownership.org/terms-and-conditions"
  PUBLISHER = RegisterBodsV2::Publisher.new(
    name: "OpenOwnership Register",
    url: "https://register.openownership.org"
  )
end
