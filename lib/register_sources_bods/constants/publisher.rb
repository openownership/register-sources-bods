# frozen_string_literal: true

require_relative '../structs/publisher'

module RegisterSourcesBods
  BODS_VERSION = '0.2'
  BODS_LICENSE = 'https://register.openownership.org/terms-and-conditions'
  PUBLISHER    = RegisterSourcesBods::Publisher.new(
    name: 'OpenOwnership Register',
    url: 'https://register.openownership.org'
  )
end
