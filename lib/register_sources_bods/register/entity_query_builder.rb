# frozen_string_literal: true

module RegisterSourcesBods
  module Register
    class EntityQueryBuilder
      EXCLUDED_TERMS_REGEX = /\b(llp|llc|plc|inc|ltd|limited)\b/i

      def build_statement_type_query(statement_type)
        {
          bool: {
            filter: [
              build_term_query(:statementType, statement_type)
            ].compact
          }
        }
      end

      def build_query(search_params, exclude_identifiers: [])
        query = build_normalise_query(search_params[:q])

        {
          bool: {
            must: [
              if exclude_identifiers.empty?
                nil
              else
                {
                  nested: {
                    path: 'identifiers',
                    query: {
                      bool: {
                        must_not: exclude_identifiers.uniq.map do |exclude_identifier|
                          { match: { 'identifiers.id': { query: exclude_identifier.id } } }
                        end
                      }
                    }
                  }
                }
              end,
              {
                bool: {
                  should: [
                    {
                      match_phrase: {
                        name: {
                          query:,
                          slop: 50
                        }
                      }
                    },
                    {
                      nested: {
                        path: 'names',
                        query: {
                          bool: {
                            must: [
                              {
                                match_phrase: {
                                  'names.fullName': {
                                    query:,
                                    slop: 50
                                  }
                                }
                              }
                            ]
                          }
                        }
                      }
                    },
                    {
                      nested: {
                        path: 'identifiers',
                        query: {
                          bool: {
                            must: [
                              {
                                term: {
                                  'identifiers.id': query
                                }
                              }
                            ]
                          }
                        }
                      }
                    }
                  ],
                  minimum_should_match: 1,
                  filter: build_filters(search_params),
                  must_not: {
                    match: { 'metadata.replaced': true }
                  }
                }
              }
            ].compact
          }
        }
      end

      def build_fallback_query(search_params, exclude_identifiers: [])
        query = build_normalise_query(search_params[:q])

        {
          bool: {
            must: [
              if exclude_identifiers.empty?
                nil
              else
                {
                  nested: {
                    path: 'identifiers',
                    query: {
                      bool: {
                        must_not: exclude_identifiers.uniq.map do |exclude_identifier|
                          { match: { 'identifiers.id': { query: exclude_identifier.id } } }
                        end
                      }
                    }
                  }
                }
              end,
              {
                bool: {
                  should: [
                    {
                      match_phrase: {
                        name: {
                          query:
                        }
                      }
                    },
                    {
                      nested: {
                        path: 'names',
                        query: {
                          bool: {
                            must: [
                              {
                                match_phrase: {
                                  'names.fullName': {
                                    query:
                                  }
                                }
                              }
                            ]
                          }
                        }
                      }
                    },
                    {
                      nested: {
                        path: 'identifiers',
                        query: {
                          bool: {
                            must: [
                              {
                                term: {
                                  'identifiers.id': query
                                }
                              }
                            ]
                          }
                        }
                      }
                    }
                  ],
                  minimum_should_match: 1,
                  filter: build_filters(search_params),
                  must_not: {
                    match: { 'metadata.replaced': true }
                  }
                }
              }
            ].compact
          }
        }
      end

      def aggregations
        {
          type: {
            terms: {
              field: :statementType
            }
          }
          # country: {
          #    terms: {
          #        field: :country_code,
          #    },
          # },
        }
      end

      def build_filters(search_params)
        [
          build_term_query(:statementType, search_params[:type])
          # build_term_query(:country_code, search_params[:country])
        ].compact
      end

      def build_term_query(key, value)
        return unless value

        {
          term: {
            key => value
          }
        }
      end

      def build_normalise_query(query)
        return '' if query.blank?

        query.gsub(EXCLUDED_TERMS_REGEX, '').strip
      end
    end
  end
end
