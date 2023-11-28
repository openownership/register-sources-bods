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
      identifier = obj.identifiers&.select do |i|
        i&.schemeName == IDENTIFIER_NAME_REG
      end&.first&.id
      [
        obj.statementID.ljust(20),
        identifier.to_s.ljust(30),
        obj.statementType.ljust(30),
        obj.name
      ].join(' ')
    end

    def self.person_statement(obj)
      identifier = obj.identifiers&.select do |i|
        i&.schemeName == IDENTIFIER_NAME_REG
      end&.first&.id
      [
        obj.statementID.ljust(20),
        identifier.to_s.ljust(30),
        obj.statementType.ljust(30),
        obj.names.first&.fullName
      ].join(' ')
    end

    def self.ownership_or_control_statement(obj)
      [
        obj.statementID.ljust(20),
        nil.to_s.ljust(30),
        obj.statementType.ljust(30)
      ].join(' ')
    end
  end
end
