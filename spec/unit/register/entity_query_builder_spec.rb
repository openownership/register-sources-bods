require 'json'

require 'register_sources_bods/structs/bods_statement'
require 'register_sources_bods/register/entity'
require 'register_sources_bods/register/entity_query_builder'

RSpec.describe RegisterSourcesBods::Register::EntityQueryBuilder do
  subject { described_class.new }

  let(:search_params) { { q: "Some Company Limited" } }

  describe '#build_query' do
    context 'when exclude_identifiers not provided' do
      it 'builds query' do
        result = subject.build_query search_params

        expect(result).to eq(
          {
            bool: {
              must: [
                {
                  bool: {
                    filter: [],
                    minimum_should_match: 1,
                    should: [
                      {
                        match_phrase: {
                          name: {
                            query: "Some Company",
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
                                      query: "Some Company",
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
                            query: "Some Company",
                          },
                        },
                      },
                    ],
                  },
                },
              ],
            },
          },
        )
      end
    end

    context 'when exclude_identifiers provided' do
      let(:exclude_identifiers) { [double(id: 'abc')] }

      it 'builds query' do
        result = subject.build_query(search_params, exclude_identifiers:)

        expect(result).to eq(
          {
            bool: {
              must: [
                {
                  nested: {
                    path: "identifiers",
                    query: {
                      bool: {
                        must_not: [
                          { match: { 'identifiers.id': { query: "abc" } } },
                        ],
                      },
                    },
                  },
                },
                {
                  bool: {
                    filter: [],
                    minimum_should_match: 1,
                    should: [
                      {
                        match_phrase: {
                          name: {
                            query: "Some Company",
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
                                      query: "Some Company",
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
                            query: "Some Company",
                          },
                        },
                      },
                    ],
                  },
                },
              ],
            },
          },
        )
      end
    end
  end

  describe '#build_fallback_query' do
    context 'when exclude_identifiers not provided' do
      it 'builds query' do
        result = subject.build_fallback_query search_params

        expect(result).to eq(
          {
            bool: {
              must: [
                {
                  bool: {
                    filter: [],
                    minimum_should_match: 1,
                    should: [
                      {
                        match_phrase: {
                          name: {
                            query: "Some Company",
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
                                      query: "Some Company",
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
                            query: "Some Company",
                          },
                        },
                      },
                    ],
                  },
                },
              ],
            },
          },
        )
      end
    end

    context 'when exclude_identifiers provided' do
      let(:exclude_identifiers) { [double(id: 'abc')] }

      it 'builds query' do
        result = subject.build_fallback_query(search_params, exclude_identifiers:)

        expect(result).to eq(
          {
            bool: {
              must: [
                {
                  nested: {
                    path: "identifiers",
                    query: {
                      bool: {
                        must_not: [
                          { match: { 'identifiers.id': { query: "abc" } } },
                        ],
                      },
                    },
                  },
                },
                {
                  bool: {
                    filter: [],
                    minimum_should_match: 1,
                    should: [
                      {
                        match_phrase: {
                          name: {
                            query: "Some Company",
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
                                      query: "Some Company",
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
                            query: "Some Company",
                          },
                        },
                      },
                    ],
                  },
                },
              ],
            },
          },
        )
      end
    end
  end
end
