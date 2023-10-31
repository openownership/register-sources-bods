require 'xxhash'

require 'register_sources_bods/structs/interest'
require 'register_sources_bods/structs/ownership_or_control_statement'
require 'register_sources_bods/structs/entity_statement'
require 'register_sources_bods/structs/share'
require 'register_sources_bods/constants/publisher'
require 'register_sources_bods/structs/publication_details'
require 'register_sources_bods/structs/source'
require 'register_sources_bods/structs/subject'

module RegisterSourcesBods
  module Transformer
    class OwnershipOrControlStatement
      UnsupportedSourceStatementTypeError = Class.new(StandardError)

      ID_PREFIX = 'openownership-register-'.freeze

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
          interestedParty: interested_party,
        ).compact]
      end

      private

      attr_reader :source_statement, :target_statement, :bods_record

      def subject
        RegisterSourcesBods::Subject.new(
          describedByEntityStatement: target_statement.statementID,
        )
      end

      def interested_party
        case source_statement.statementType
        when RegisterSourcesBods::StatementTypes['personStatement']
          RegisterSourcesBods::InterestedParty[{
            describedByPersonStatement: source_statement.statementID,
          }]
        when RegisterSourcesBods::StatementTypes['entityStatement']
          case source_statement.entityType
          when RegisterSourcesBods::EntityTypes['unknownEntity']
            RegisterSourcesBods::InterestedParty[{
              unspecified: source_statement.unspecifiedEntityDetails,
            }.compact]
          else
            RegisterSourcesBods::InterestedParty[{
              describedByEntityStatement: source_statement.statementID,
            }]
          end
        else
          raise UnsupportedSourceStatementTypeError
        end
      end
    end
  end
end
