# frozen_string_literal: true

require 'register_sources_bods/types'

require 'register_sources_bods/enums/interest_levels'
require 'register_sources_bods/enums/interest_types'
require 'register_sources_bods/structs/share'

module RegisterSourcesBods
  class Interest < Dry::Struct
    transform_keys(&:to_sym)

    attribute? :type, InterestTypes
    attribute? :interestLevel, InterestLevels
    attribute? :beneficialOwnershipOrControl, Types::Params::Bool
    attribute? :details, Types::String
    attribute? :share, Share
    attribute? :startDate, Types::String
    attribute? :endDate, Types::String
  end
end
