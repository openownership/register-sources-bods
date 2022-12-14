require 'register_sources_bods/config/elasticsearch'
require 'register_sources_bods/structs/bods_statement'

module RegisterSourcesBods
  module Repositories
    class BodsStatementRepository      
      UnknownRecordKindError = Class.new(StandardError)
      ElasticsearchError = Class.new(StandardError)

      SearchResult = Struct.new(:record, :score)

      def initialize(client: Config::ELASTICSEARCH_CLIENT, index: Config::ES_BODS_V2_INDEX)
        @client = client
        @index = index
      end

      def get(statement_id)
        process_results(
          client.search(
            index: index,
            body: {
              query: {
                bool: {
                  must: [
                    {
                      match: {
                        statementID: {
                          query: statement_id
                        }
                      }
                    }
                  ]
                }
              }
            }
          )
        ).first&.record
      end

      def list_all
        process_results(
          client.search(
            index: index,
            body: {
              query: {
                bool: {}
              }
            }
          )
        ).map(&:record)
      end

      def list_for_identifier(identifier)
        process_results(
          client.search(
            index: index,
            body: {
              query: {
                nested: {
                  path: "identifiers",
                  query: {
                    bool: {
                      must: [
                        { match: { "identifiers.id": { query: identifier.id } } },
                        { match: { "identifiers.scheme": { query: identifier.scheme } } },
                        { match: { "identifiers.schemeName": { query: identifier.schemeName } } },
                        { match: { "identifiers.uri": { query: identifier.uri } } },
                      ].select { |sel| sel[:match].values.first[:query] }
                    }
                  }
                }
              }
            }
          )
        ).map(&:record)
      end

      def list_matching_at_least_one_identifier(identifiers)
        process_results(
          client.search(
            index: index,
            body: {
              query: {
                nested: {
                  path: "identifiers",
                  query: {
                    bool: {
                      should: identifiers.map { |identifier|
                        {
                          bool: {
                            must: [
                              { match: { "identifiers.id": { query: identifier.id } } },
                              { match: { "identifiers.scheme": { query: identifier.scheme } } },
                              { match: { "identifiers.schemeName": { query: identifier.schemeName } } },
                              { match: { "identifiers.uri": { query: identifier.uri } } },
                            ].select { |sel| sel[:match].values.first[:query] }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          )
        ).map(&:record)
      end

      def store(records)
        return true if records.empty?

        operations = records.map do |record|
          {
            index:  {
              _index: index,
              _id: calculate_id(record),
              data: record.to_h
            }
          }
        end

        result = client.bulk(body: operations)

        if result['errors']
          print result, "\n\n"
          raise ElasticsearchError, errors: result['errors']
        end

        true
      end

      private

      attr_reader :client, :index

      def calculate_id(record)
        record.statementID
      end

      def process_results(results)
        hits = results.dig('hits', 'hits') || []
        hits = hits.sort { |hit| hit['_score'] }.reverse

        mapped = hits.map do |hit|
          SearchResult.new(map_es_record(hit['_source']), hit['_score'])
        end

        mapped.sort_by(&:score).reverse
      end

      def map_es_record(record)
        BodsStatement[record.compact]
      end
    end
  end
end
