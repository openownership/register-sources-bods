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

            def build_query(search_params)
                query = build_normalise_query(search_params[:q])

                {
                    bool: {
                        should: [
                            {
                                match_phrase: {
                                    name: {
                                        query: query,
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
                                                        "names.fullName": {
                                                            query: query,
                                                            slop: 50,
                                                        }
                                                    }
                                                }
                                            ]
                                        }
                                    }
                                }
                            },
                            #{
                            #    match_phrase: {
                            #        name_transliterated: {
                            #            query: query,
                            #            slop: 50,
                            #        },
                            #    },
                            #},
                            {
                                match: {
                                    company_number: {
                                        query: query,
                                    },
                                },
                            },
                        ],
                        minimum_should_match: 1,
                        filter: build_filters(search_params),
                    },
                }
            end

            def build_fallback_query(search_params)
                query = build_normalise_query(search_params[:q])

                {
                    bool: {
                        should: [
                            {
                                match: {
                                    name: {
                                        query: query,
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
                                                        "names.fullName": {
                                                            query: query,
                                                        }
                                                    }
                                                }
                                            ]
                                        }
                                    }
                                }
                            },
                            #{
                            #    match: {
                            #        name_transliterated: {
                            #            query: query,
                            #        },
                            #    },
                            #},
                        ],
                        minimum_should_match: 1,
                        filter: build_filters(search_params),
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
