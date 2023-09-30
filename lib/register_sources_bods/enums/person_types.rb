# frozen_string_literal: true

require 'register_sources_bods/types'

module RegisterSourcesBods
  PersonTypes = Types::String.enum(
    'knownPerson',
    'anonymousPerson',
    'unknownPerson'
  )
end
