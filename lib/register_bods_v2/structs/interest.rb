require 'register_bods_v2/types'

require 'register_bods_v2/enums/interest_levels'
require 'register_bods_v2/enums/interest_types'
require 'register_bods_v2/structs/share'

module RegisterBodsV2
  class Interest < Dry::Struct
    transform_keys(&:to_sym)

    attribute? :type, InterestTypes
    attribute? :interestLevel, InterestLevels
    attribute? :beneficialOwnershipOrControl, Types::Nominal::Bool
    attribute? :details, Types::String
    attribute? :share, Share
    attribute? :startDate, Types::String
    attribute? :endDate, Types::String
  end
end
