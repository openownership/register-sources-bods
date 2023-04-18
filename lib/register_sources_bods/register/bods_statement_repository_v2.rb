require 'register_sources_bods/repositories/bods_statement_repository'
require 'register_sources_bods/structs/identifier'

# TODO: this should fetch a BODS record
class BodsStatementRepositoryV2
  def initialize
    @repository = RegisterSourcesBods::Repositories::BodsStatementRepository.new
  end

  def find(statement_id)
    repository.get(statement_id)
  end

  def find_by_entity_id(entity_id)
    find_by_entity_uri("/entities/#{entity_id}")
  end

  def find_by_entity_ids(entity_ids)
    find_by_entity_uris(entity_ids.map { |entity_id| "/entities/#{entity_id}" })
  end

  def find_by_entity_uri(uri)
    find_by_entity_uris([uri]).first
  end

  def find_by_entity_uris(uris)
    identifiers = uris.uniq.map do |uri|
      RegisterSourcesBods::Identifier[{
        id: uri,
        schemeName: "OpenOwnership Register",
        uri: uri
      }]
    end

    records = repository.list_matching_at_least_one_identifier(identifiers)

    # find record which hasn't been replaced
    replaced = records.flat_map { |record| record.replacesStatements }.compact.uniq

    records.filter { |record| !replaced.include?(record.statementID) }
  end

  def list_matching_at_least_one_identifier(identifiers)
    repository.list_matching_at_least_one_identifier(identifiers)
  end

  def list_for_subject_or_interested_party(**kwargs)
    repository.list_for_subject_or_interested_party(**kwargs)
  end

  # write proper mapper for identifiers

  private

  attr_reader :repository
end
