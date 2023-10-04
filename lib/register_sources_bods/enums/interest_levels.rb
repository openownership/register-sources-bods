# frozen_string_literal: true

require_relative '../types'

module RegisterSourcesBods
  InterestLevels = Types::String.enum(
    'direct',
    'indirect',
    'unknown'
  )
end
