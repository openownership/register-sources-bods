# frozen_string_literal: true

require 'xxhash'

require_relative '../constants/publisher'
require_relative '../structs/entity_statement'
require_relative '../structs/interest'
require_relative '../structs/ownership_or_control_statement'
require_relative '../structs/publication_details'
require_relative '../structs/share'
require_relative '../structs/source'
require_relative '../structs/subject'

module RegisterSourcesBods
  module Transformer
    class OwnershipOrControlStatement
      UnsupportedSourceStatementTypeError = Class.new(StandardError)

      ID_PREFIX = 'openownership-register-'

      def self.call(bods_record, **kwargs)
        new(bods_record, **kwargs).call
      end

      def initialize(
        bods_record,
        source_statement: nil,
        target_statement: nil
      )
        @bods_record = bods_record
        @source_statement = source_statement
        @target_statement = target_statement
      end

      def call
        RegisterSourcesBods::OwnershipOrControlStatement[bods_record.to_h.merge(
          subject:,
          interestedParty: interested_party
        ).compact]
      end

      private

      attr_reader :source_statement, :target_statement, :bods_record

      def subject
        RegisterSourcesBods::Subject.new(
          describedByEntityStatement: target_statement.statementID
        )
      end

      def interested_party
        case source_statement.statementType
        when RegisterSourcesBods::StatementTypes['personStatement']
          RegisterSourcesBods::InterestedParty[{
            describedByPersonStatement: source_statement.statementID
          }]
        when RegisterSourcesBods::StatementTypes['entityStatement']
          case source_statement.entityType
          when RegisterSourcesBods::EntityTypes['unknownEntity']
            RegisterSourcesBods::InterestedParty[{
              unspecified: source_statement.unspecifiedEntityDetails
            }.compact]
          else
            RegisterSourcesBods::InterestedParty[{
              describedByEntityStatement: source_statement.statementID
            }]
          end
        else
          raise UnsupportedSourceStatementTypeError
        end
      end
    end
  end
end
