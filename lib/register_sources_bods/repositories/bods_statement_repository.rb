# frozen_string_literal: true

require 'register_common/elasticsearch/query'
require 'register_common/utils/paginated_array'

require_relative '../config/elasticsearch'
require_relative '../structs/bods_statement'

module RegisterSourcesBods
  module Repositories
    class BodsStatementRepository
      ElasticsearchError = Class.new(StandardError)

      SearchResult = Struct.new(:record, :score)

      class SearchResults < Array
        def initialize(arr, total_count: nil, aggs: nil)
          @total_count = total_count || arr.to_a.count
          @aggs = aggs

          super(arr)
        end

        attr_reader :total_count, :aggs
      end

      def initialize(client: Config::ELASTICSEARCH_CLIENT, index: Config::ELASTICSEARCH_INDEX, await_refresh: false)
        @client = client
        @index = index
        @await_refresh = await_refresh
      end

      def each(q_must: [], q_filter: [], q_should: [], q_must_not: [], latest: true, &block)
        q_must_not << { match: { 'metadata.replaced': true } } if latest
        q = {
          index:,
          body: {
            query: {
              bool: {
                must: q_must,
                filter: q_filter,
                should: q_should,
                must_not: q_must_not
              }
            }
          }
        }
        RegisterCommon::Elasticsearch::Query.search_scroll(client, q, &block)
      end

      def get(statement_id)
        process_results(
          client.search(
            index:,
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

      def get_bulk(statement_ids)
        return [] unless statement_ids && !statement_ids.empty?

        process_results(
          client.search(
            index:,
            body: {
              query: {
                bool: {
                  should: statement_ids.map do |statement_id|
                    {
                      bool: {
                        must: [
                          { match: { statementID: { query: statement_id } } }
                        ]
                      }
                    }
                  end
                }
              },
              size: 10_000
            }
          )
        ).map(&:record)
      end

      def list_all(query: nil)
        query ||= {
          bool: {}
        }

        process_results(
          client.search(
            index:,
            body: {
              query:
            }
          )
        ).map(&:record)
      end

      def list_for_identifier(identifier)
        process_results(
          client.search(
            index:,
            body: {
              query: {
                nested: {
                  path: 'identifiers',
                  query: {
                    bool: {
                      must: [
                        { match: { 'identifiers.id': { query: identifier.id } } },
                        { match: { 'identifiers.scheme': { query: identifier.scheme } } },
                        { match: { 'identifiers.schemeName': { query: identifier.schemeName } } },
                        { match: { 'identifiers.uri': { query: identifier.uri } } }
                      ].select { |sel| sel[:match].values.first[:query] }
                    }
                  }
                }
              },
              size: 10_000
            }
          )
        ).map(&:record)
      end

      def list_matching_at_least_one_identifier(identifiers, latest: false)
        return [] if identifiers.empty?

        q_must_not = []
        q_must_not << { match: { 'metadata.replaced': true } } if latest
        process_results(
          client.search(
            index:,
            body: {
              query: {
                bool: {
                  must: {
                    nested: {
                      path: 'identifiers',
                      query: {
                        bool: {
                          should: [
                            { terms: { 'identifiers.id': identifiers.map(&:id).compact } },
                            { terms: { 'identifiers.uri': identifiers.map(&:uri).compact } }
                          ].filter { |a| !a[:terms].values.first.empty? }
                        }
                      }
                    }
                  },
                  must_not: q_must_not
                }
              },
              size: 10_000
            }
          )
        ).map(&:record)
      end

      def list_matching_at_least_one_source(sources)
        return [] if sources.empty?

        process_results(
          client.search(
            index:,
            body: {
              query: {
                nested: {
                  path: 'source',
                  query: {
                    bool: {
                      should: [
                        { terms: { 'source.url': sources.map(&:url).compact } }
                      ].filter { |a| !a[:terms].values.first.empty? }
                    }
                  }
                }
              },
              size: 10_000
            }
          )
        ).map(&:record)
      end

      def list_associated(statement_ids, subject: true, interested_party: true)
        conditions = statement_ids.map do |statement_id|
          [
            if subject
              {
                nested: {
                  path: 'subject',
                  query: {
                    bool: {
                      must: [
                        { match: { 'subject.describedByEntityStatement': { query: statement_id } } }
                      ]
                    }
                  }
                }
              }
            end,
            if interested_party
              {
                nested: {
                  path: 'interestedParty',
                  query: {
                    bool: {
                      should: [
                        { match: { 'interestedParty.describedByEntityStatement': { query: statement_id } } },
                        { match: { 'interestedParty.describedByPersonStatement': { query: statement_id } } }
                      ]
                    }
                  }
                }
              }
            end
          ]
        end.flatten.compact

        return [] if conditions.empty?

        process_results(
          client.search(
            index:,
            body: {
              query: {
                bool: { should: conditions }
              },
              size: 10_000
            }
          )
        ).map(&:record)
      end

      def list_for_subject_or_interested_party(subject_statement_id: nil, interested_party_statement_id: nil,
                                               match_both: false)
        raise 'must provide at least one' unless subject_statement_id || interested_party_statement_id

        conditions = []

        if subject_statement_id
          conditions << {
            nested: {
              path: 'subject',
              query: {
                bool: {
                  must: [
                    { match: { 'subject.describedByEntityStatement': { query: subject_statement_id } } }
                  ]
                }
              }
            }
          }
        end

        if interested_party_statement_id
          # rubocop:disable Layout/LineLength
          conditions << {
            nested: {
              path: 'interestedParty',
              query: {
                bool: {
                  should: [
                    { match: { 'interestedParty.describedByEntityStatement': { query: interested_party_statement_id } } },
                    { match: { 'interestedParty.describedByPersonStatement': { query: interested_party_statement_id } } }
                  ]
                }
              }
            }
          }
          # rubocop:enable Layout/LineLength
        end

        process_results(
          client.search(
            index:,
            body: {
              query: {
                bool: match_both ? { must: conditions } : { should: conditions }
              },
              size: 10_000
            }
          )
        ).map(&:record)
      end

      def store(records, await_refresh: false)
        return true if records.empty?

        operations = records.map do |record|
          {
            index: {
              _index: index,
              _id: calculate_id(record),
              data: record.to_h
            }
          }
        end

        refresh = await_refresh || @await_refresh ? :wait_for : false

        result = client.bulk(body: operations, refresh:)

        if result['errors']
          print result, "\n\n"
          raise ElasticsearchError, errors: result['errors']
        end

        true
      end

      def mark_replaced_statements(records, await_refresh: false)
        replaced_ids = records.map(&:replacesStatements).flatten.uniq.compact

        return {} if replaced_ids.empty?

        client.update_by_query(
          index:,
          refresh: (await_refresh || @await_refresh),
          body: {
            script: {
              lang: 'painless',
              source: "ctx._source['metadata.replaced'] = true"
            },
            query: {
              bool: {
                must: {
                  terms: { statementID: replaced_ids }
                },
                must_not: {
                  match: { 'metadata.replaced': true }
                }
              }
            }
          }
        )
      end

      def search(query, aggs: nil, page: 1, per_page: 10)
        if (page.to_i >= 1) && (per_page.to_i >= 1)
          page = page.to_i
          per_page = per_page.to_i
          from = (page - 1) * per_page
          per_page
        else
          page = 1
          per_page = 10
          from = nil
          nil
        end

        res = process_results(
          client.search(
            index:,
            body: {
              from:,
              size: per_page,
              query:,
              aggregations: aggs
            }.compact
          )
        )

        RegisterCommon::Utils::PaginatedArray.new(
          res,
          current_page: page,
          records_per_page: per_page,
          limit_value: nil,
          total_count: res.total_count,
          aggs: res.aggs
        )
      end

      def count(query)
        res = client.count(
          index:,
          body: {
            query:
          }.compact
        )

        res['count']
      end

      private

      attr_reader :client, :index

      def calculate_id(record)
        record.statementID
      end

      def process_results(results)
        # print "Elasticsearch: ", results, "\n\n"
        hits = results.dig('hits', 'hits') || []
        hits = hits.sort { |hit| hit['_score'] }.reverse # rubocop:disable Lint/UnexpectedBlockArity # FIXME
        total_count = results.dig('hits', 'total', 'value') || 0

        mapped = hits.map do |hit|
          SearchResult.new(map_es_record(hit['_source']), hit['_score'])
        end

        SearchResults.new(
          mapped.sort_by(&:score).reverse,
          total_count:,
          aggs: results['aggregations']
        )
      end

      def map_es_record(record)
        BodsStatement[record.compact]
      end
    end
  end
end
