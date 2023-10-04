# frozen_string_literal: true

require_relative '../types'

module RegisterSourcesBods
  PersonTypes = Types::String.enum(
    'knownPerson',
    'anonymousPerson',
    'unknownPerson'
  )
end
