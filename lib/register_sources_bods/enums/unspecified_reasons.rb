require 'register_sources_bods/types'

module RegisterSourcesBods
  UnspecifiedReasons = Types::String.enum(
    'no-beneficial-owners',
    'subject-unable-to-confirm-or-identify-beneficial-owner',
    'interested-party-has-not-provided-information',
    'subject-exempt-from-disclosure',
    'interested-party-exempt-from-disclosure',
    'unknown',
    'information-unknown-to-publisher'
  )
end
