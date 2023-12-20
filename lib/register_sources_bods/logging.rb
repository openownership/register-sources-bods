# frozen_string_literal: true

require_relative 'constants/errors'
require_relative 'constants/identifiers'

module RegisterSourcesBods
  module Logging
    def self.log(obj)
      out = case obj
            when BodsStatement
              bods_statement(obj)
            else
              raise Errors::UnknownRecordKindError
            end
      puts out
    end

    def self.bods_statement(obj)
      case obj
      when EntityStatement
        entity_statement(obj)
      when PersonStatement
        person_statement(obj)
      when OwnershipOrControlStatement
        ownership_or_control_statement(obj)
      else
        raise Errors::UnknownRecordKindError
      end
    end

    def self.entity_statement(obj)
      [
        format_id(obj.statementID),
        format_type(obj.statementType),
        obj.name
      ].join(' ')
    end

    def self.person_statement(obj)
      [
        format_id(obj.statementID),
        format_type(obj.statementType),
        obj.names.first&.fullName
      ].join(' ')
    end

    def self.ownership_or_control_statement(obj)
      [
        format_id(obj.statementID),
        format_type(obj.statementType)
      ].join(' ')
    end

    def self.format_id(id)
      id.ljust(36)
    end

    def self.format_type(type)
      type.chomp('Statement').ljust(18)
    end
  end
end
