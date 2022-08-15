require 'register_bods_v2/types'

require 'register_bods_v2/enums/interest_levels'
require 'register_bods_v2/enums/interest_types'
require 'register_bods_v2/structs/share'

module RegisterBodsV2
  class Interest < Dry::Struct
    attribute :type, InterestTypes.optional
    attribute :interestLevel, InterestLevels.optional
    attribute :beneficialOwnershipOrControl, Types::String.optional
    attribute :details, Types::String.optional
    attribute :share, Share.optional
    attribute :startDate, Types::String.optional
    attribute :endDate, Types::String.optional
  end
end
