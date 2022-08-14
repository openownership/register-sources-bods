require 'register_bods_v2/types'

module RegisterBodsV2
  AnnotationMotivations = Types::String.enum(
    'commenting',
    'correcting',
    'identifying',
    'linking',
    'transformation'
  )
end
