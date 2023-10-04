# frozen_string_literal: true

require_relative '../types'

module RegisterSourcesBods
  StatementTypes = Types::String.enum(
    'personStatement',
    'entityStatement',
    'ownershipOrControlStatement'
  )
end
