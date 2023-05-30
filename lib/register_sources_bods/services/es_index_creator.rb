require 'register_sources_bods/config/elasticsearch'

module RegisterSourcesBods
  module Services
    class EsIndexCreator
      def initialize(
        client: Config::ELASTICSEARCH_CLIENT,
        es_index: Config::ES_BODS_V2_INDEX
      )
        @client = client
        @es_index = es_index
      end

      def create_es_index
        client.indices.create index: es_index, body: {
          mappings: {
            properties: {
              addresses: { # Array[Address]
                type: "nested",
                properties: {
                  type: {
                    type: "keyword",
                  },
                  address: {
                    type: "text",
                    fields: {
                      raw: {
                        type: "keyword",
                      },
                    },
                  },
                  postCode: {
                    type: "keyword",
                  },
                  country: {
                    type: "keyword",
                  },
                },
              },
              alternateNames: {
                type: "text",
                fields: {
                  raw: {
                    type: "keyword",
                  },
                },
              },
              annotations: { # Types.Array(Annotation)
                type: "nested",
                properties: {
                  statementPointerTarget: {
                    type: "keyword", # Types::String.optional
                  },
                  creationDate: {
                    type: "keyword", # Types::String.optional
                  },
                  createdBy: {
                    type: "keyword", # Types::String.optional
                  },
                  motivation: {
                    type: "keyword", # AnnotationMotivations
                  },
                  description: {
                    type: "keyword", # Types::String.optional
                  },
                  transformedContent: {
                    type: "keyword", # Types::String.optional
                  },
                  url: {
                    type: "keyword", # Types::String.optional
                  },
                },
              },
              birthDate: {
                type: "keyword", # Types::String.optional
              },
              componentStatementIDs: {
                type: "keyword", # Types.Array(Types::String).optional
              },
              deathDate: {
                type: "keyword", # Types::String.optional
              },
              dissolutionDate: {
                type: "keyword", # Types::String.optional
              },
              entityType: {
                type: "keyword", # EntityTypes
              },
              foundingDate: {
                type: "keyword", # Types::String.optional
              },
              hasPepStatus: {
                type: "keyword", # Types::String.optional
              },
              identifiers: { # Types.Array(Identifier).optional
                type: "nested",
                properties: {
                  id: {
                    type: "keyword", # Types::String.optional
                  },
                  scheme: {
                    type: "keyword", # Types::String.optional
                  },
                  schemeName: {
                    type: "keyword", # Types::String.optional
                  },
                  uri: {
                    type: "keyword", # Types::String.optional
                  },
                },
              },
              incorporatedInJurisdiction: {
                type: "nested",
                properties: {
                  name: {
                    type: "keyword",
                  },
                  code: {
                    type: "keyword",
                  },
                },
              },
              interestedParty: { # InterestedParty.optional
                type: "nested",
                properties: {
                  describedByEntityStatement: {
                    type: "keyword", # Types::String.optional
                  },
                  describedByPersonStatement: {
                    type: "keyword", # Types::String.optional
                  },
                  unspecified: {
                    type: "nested",
                    properties: {
                      reason: {
                        type: "keyword", # UnspecifiedReasons
                      },
                      description: {
                        type: "keyword", # Types::String.optional
                      },
                    },
                  },
                },
              },
              interests: {
                type: "nested",
                properties: {
                  type: {
                    type: "keyword",
                  },
                  interestLevel: {
                    type: "keyword",
                  },
                  beneficialOwnershipOrControl: {
                    type: "boolean",
                  },
                  details: {
                    type: "keyword",
                  },
                  share: {
                    type: "nested",
                    properties: {
                      exact: {
                        type: "float",
                      },
                      maximum: {
                        type: "float",
                      },
                      minimum: {
                        type: "float",
                      },
                      exclusiveMinimum: {
                        type: "boolean",
                      },
                      exclusiveMaximum: {
                        type: "boolean",
                      },
                    },
                  },
                  startDate: {
                    type: "keyword",
                  },
                  endDate: {
                    type: "keyword",
                  },
                },
              },
              isComponent: {
                type: "keyword", # Types::String.optional
              },
              name: {
                type: "text",
                fields: {
                  raw: {
                    type: "keyword",
                  },
                },
              },
              names: { # Array[Name]
                type: "nested",
                properties: {
                  type: {
                    type: "keyword", # NameTypes
                  },
                  fullName: {
                    type: "text",
                    fields: {
                      raw: {
                        type: "keyword",
                      },
                    },
                  },
                  familyName: {
                    type: "text",
                    fields: {
                      raw: {
                        type: "keyword",
                      },
                    },
                  },
                  givenName: {
                    type: "text",
                    fields: {
                      raw: {
                        type: "keyword",
                      },
                    },
                  },
                  patronymicName: {
                    type: "text",
                    fields: {
                      raw: {
                        type: "keyword",
                      },
                    },
                  },
                },
              },
              nationalities: { # Array[Country]
                type: "nested",
                properties: {
                  name: {
                    type: "text",
                    fields: {
                      raw: {
                        type: "keyword",
                      },
                    },
                  },
                  code: {
                    type: "keyword",
                  },
                },
              },
              pepStatusDetails: { # PepStatusDetails.optional
                type: "nested",
                properties: {
                  reason: {
                    type: "keyword", # Types::String.optional
                  },
                  missingInfoReason: {
                    type: "keyword", # UnspecifiedReasons
                  },
                  jurisdiction: {
                    type: "keyword", # Types::String.optional
                  },
                  startDate: {
                    type: "keyword", # Types::String.optional
                  },
                  endDate: {
                    type: "keyword", # Types::String.optional
                  },
                  source: { # Source.optional
                    type: "nested",
                    properties: {
                      type: {
                        type: "keyword", # SourceTypes
                      },
                      description: {
                        type: "keyword", # Types::String.optional
                      },
                      url: {
                        type: "keyword", # Types::String.optional
                      },
                      retrievedAt: {
                        type: "keyword", # Types::String.optional
                      },
                      assertedBy: { # Agent.optional
                        type: "nested",
                        properties: {
                          name: {
                            type: "keyword", # Types::String.optional
                          },
                          url: {
                            type: "keyword", # Types::String.optional
                          },
                        },
                      },
                    },
                  },
                },
              },
              personType: {
                type: "keyword", # PersonTypes
              },
              placeOfBirth: {
                type: "nested",
                properties: {
                  type: {
                    type: "keyword",
                  },
                  address: {
                    type: "text",
                    fields: {
                      raw: {
                        type: "keyword",
                      },
                    },
                  },
                  postCode: {
                    type: "keyword",
                  },
                  country: {
                    type: "keyword",
                  },
                },
              },
              placeOfResidence: {
                type: "nested",
                properties: {
                  type: {
                    type: "keyword",
                  },
                  address: {
                    type: "text",
                    fields: {
                      raw: {
                        type: "keyword",
                      },
                    },
                  },
                  postCode: {
                    type: "keyword",
                  },
                  country: {
                    type: "keyword",
                  },
                },
              },
              publicationDetails: { # PublicationDetails.optional
                type: "nested",
                properties: {
                  publicationDate: {
                    type: "keyword", # Types::String.optional
                  },
                  bodsVersion: {
                    type: "keyword", # Types::String.optional
                  },
                  license: {
                    type: "keyword", # Types::String.optional
                  },
                  publisher: { # Publisher
                    type: "nested",
                    properties: {
                      name: {
                        type: "keyword", # Types::String.optional
                      },
                      url: {
                        type: "keyword", # Types::String.optional
                      },
                    },
                  },
                },
              },
              replacesStatements: {
                type: "keyword", # Types::String.optional
              },
              source: { # Source.optional
                type: "nested",
                properties: {
                  type: {
                    type: "keyword", # SourceTypes
                  },
                  description: {
                    type: "keyword", # Types::String.optional
                  },
                  url: {
                    type: "keyword", # Types::String.optional
                  },
                  retrievedAt: {
                    type: "keyword", # Types::String.optional
                  },
                  assertedBy: { # Agent.optional
                    type: "nested",
                    properties: {
                      name: {
                        type: "keyword", # Types::String.optional
                      },
                      url: {
                        type: "keyword", # Types::String.optional
                      },
                    },
                  },
                },
              },
              statementID: {
                type: "keyword", # Types::String.optional
              },
              statementType: {
                type: "keyword", # StatementTypes
              },
              statementDate: {
                type: "keyword", # Types::String.optional
              },
              subject: { # Subject.optional
                type: "nested",
                properties: {
                  describedByEntityStatement: {
                    type: "keyword", # Types::String.optional
                  },
                },
              },
              taxResidencies: {
                type: "nested",
                properties: {
                  name: {
                    type: "keyword",
                  },
                  code: {
                    type: "keyword",
                  },
                },
              },
              unspecifiedEntityDetails: {
                type: "nested",
                properties: {
                  reason: {
                    type: "keyword", # UnspecifiedReasons
                  },
                  description: {
                    type: "keyword", # Types::String.optional
                  },
                },
              },
              unspecifiedPersonDetails: {
                type: "nested",
                properties: {
                  reason: {
                    type: "keyword", # UnspecifiedReasons
                  },
                  description: {
                    type: "keyword", # Types::String.optional
                  },
                },
              },
              uri: {
                type: "keyword", # Types::String.optional
              },
            },
          },
        }
      end

      private

      attr_reader :client, :es_index
    end
  end
end
