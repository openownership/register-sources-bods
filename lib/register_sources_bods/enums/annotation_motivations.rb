# frozen_string_literal: true

require 'register_sources_bods/types'

module RegisterSourcesBods
  AnnotationMotivations = Types::String.enum(
    'commenting',
    'correcting',
    'identifying',
    'linking',
    'transformation'
  )
end
