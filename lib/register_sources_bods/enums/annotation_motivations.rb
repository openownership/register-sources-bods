# frozen_string_literal: true

require_relative '../types'

module RegisterSourcesBods
  AnnotationMotivations = Types::String.enum(
    'commenting',
    'correcting',
    'identifying',
    'linking',
    'transformation'
  )
end
