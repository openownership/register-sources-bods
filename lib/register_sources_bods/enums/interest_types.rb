require 'register_sources_bods/types'

module RegisterSourcesBods
  InterestTypes = Types::String.enum(
    'shareholding',
    'voting-rights',
    'appointment-of-board',
    'other-influence-or-control',
    'senior-managing-official',
    'settlor-of-trust',
    'trustee-of-trust',
    'protector-of-trust',
    'beneficiary-of-trust',
    'other-influence-or-control-of-trust',
    'rights-to-surplus-assets-on-dissolution',
    'rights-to-profit-or-income',
    'rights-granted-by-contract',
    'conditional-rights-granted-by-contract',
  )
end
