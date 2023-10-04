# frozen_string_literal: true

require_relative '../types'

module RegisterSourcesBods
  EntityTypes = Types::String.enum(
    'registeredEntity',
    'legalEntity',
    'arrangement',
    'anonymousEntity',
    'unknownEntity'
  )
end
