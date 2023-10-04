# frozen_string_literal: true

require_relative '../enums/interest_levels'
require_relative '../enums/interest_types'
require_relative '../types'
require_relative 'share'

module RegisterSourcesBods
  class Interest < Dry::Struct
    transform_keys(&:to_sym)

    attribute? :type,                         InterestTypes
    attribute? :interestLevel,                InterestLevels
    attribute? :beneficialOwnershipOrControl, Types::Params::Bool
    attribute? :details,                      Types::String
    attribute? :share,                        Share
    attribute? :startDate,                    Types::String
    attribute? :endDate,                      Types::String
  end
end
