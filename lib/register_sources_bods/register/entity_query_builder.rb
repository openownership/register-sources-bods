module RegisterSourcesBods
  module Register
    class EntityQueryBuilder
      EXCLUDED_TERMS_REGEX = /\b(llp|llc|plc|inc|ltd|limited)\b/i

      def build_statement_type_query(statement_type)
        {
          bool: {
            filter: [
              build_term_query(:statementType, statement_type),
            ].compact,
          },
        }
      end

      # builds query to find natural persons with same name and birth-date
      def build_merged_query(original_person)
        exclude_identifiers = original_person.identifiers

        query = original_person.names.first&.fullName

        {
          bool: {
            must: [
              if exclude_identifiers.empty?
                nil
              else
                {
                  nested: {
                    path: "identifiers",
                    query: {
                      bool: {
                        must_not: exclude_identifiers.uniq.map do |exclude_identifier|
                          { match: { 'identifiers.id': { query: exclude_identifier.id } } }
                        end,
                      },
                    },
                  },
                }
              end,
              # Match birth date
              if original_person.birthDate
                {
                  bool: {
                    should: {
                      match: {
                        "birthDate": { query: original_person.birthDate }, 
                      },
                    }
                  }
                }
              end,
              # Match address
              if original_person.addresses && !original_person.addresses.empty?
                {
                  bool: {
                    should: original_person.addresses.map { |address|#
                      [
                        {
                          nested: {
                            path: "addresses",
                            query: {
                              bool: {
                                must: [
                                  {
                                    match: {
                                      'addresses.address.raw': {
                                        query: address.address
                                      },
                                    },
                                  },
                                ],
                              },
                            },
                          },
                        },
                      ]
                    }.compact.flatten,
                    minimum_should_match: 1,
                  },
                }
              end,
              # Match name
              {
                bool: {
                  should: [
                    {
                      nested: {
                        path: "names",
                        query: {
                          bool: {
                            must: [
                              {
                                match_phrase: {
                                  'names.fullName': {
                                    query:,
                                    slop: 50,
                                  },
                                },
                              },
                            ],
                          },
                        },
                      },
                    },
                  ],
                  minimum_should_match: 1,
                  filter: {
                    term: {
                      statementType: 'personStatement',
                    },
                  },
                },
              },
            ].compact,
          },
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
                    path: "identifiers",
                    query: {
                      bool: {
                        must_not: exclude_identifiers.uniq.map do |exclude_identifier|
                          { match: { 'identifiers.id': { query: exclude_identifier.id } } }
                        end,
                      },
                    },
                  },
                }
              end,
              {
                bool: {
                  should: [
                    {
                      match_phrase: {
                        name: {
                          query:,
                          slop: 50,
                        },
                      },
                    },
                    {
                      nested: {
                        path: "names",
                        query: {
                          bool: {
                            must: [
                              {
                                match_phrase: {
                                  'names.fullName': {
                                    query:,
                                    slop: 50,
                                  },
                                },
                              },
                            ],
                          },
                        },
                      },
                    },
                    {
                      match: {
                        company_number: {
                          query:,
                        },
                      },
                    },
                  ],
                  minimum_should_match: 1,
                  filter: build_filters(search_params),
                },
              },
            ].compact,
          },
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
                    path: "identifiers",
                    query: {
                      bool: {
                        must_not: exclude_identifiers.uniq.map do |exclude_identifier|
                          { match: { 'identifiers.id': { query: exclude_identifier.id } } }
                        end,
                      },
                    },
                  },
                }
              end,
              {
                bool: {
                  should: [
                    {
                      match_phrase: {
                        name: {
                          query:,
                        },
                      },
                    },
                    {
                      nested: {
                        path: "names",
                        query: {
                          bool: {
                            must: [
                              {
                                match_phrase: {
                                  'names.fullName': {
                                    query:,
                                  },
                                },
                              },
                            ],
                          },
                        },
                      },
                    },
                    {
                      match: {
                        company_number: {
                          query:,
                        },
                      },
                    },
                  ],
                  minimum_should_match: 1,
                  filter: build_filters(search_params),
                },
              },
            ].compact,
          },
        }
      end

      def aggregations
        {
          type: {
            terms: {
              field: :statementType,
            },
          },
          # country: {
          #    terms: {
          #        field: :country_code,
          #    },
          # },
        }
      end

      def build_filters(search_params)
        [
          build_term_query(:statementType, search_params[:type]),
          # build_term_query(:country_code, search_params[:country])
        ].compact
      end

      def build_term_query(key, value)
        return unless value

        {
          term: {
            key => value,
          },
        }
      end

      def build_normalise_query(query)
        return '' if query.blank?

        query.gsub(EXCLUDED_TERMS_REGEX, '').strip
      end
    end
  end
end
