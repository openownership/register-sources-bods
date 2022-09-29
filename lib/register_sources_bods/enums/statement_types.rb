require 'register_sources_bods/types'

module RegisterSourcesBods
  StatementTypes = Types::String.enum(
    'personStatement',
    'entityStatement',
    'ownershipOrControlStatement'
  )
end
