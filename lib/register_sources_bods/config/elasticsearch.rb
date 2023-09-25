# frozen_string_literal: true

require 'elasticsearch'

module RegisterSourcesBods
  module Config
    ELASTICSEARCH_CLIENT = Elasticsearch::Client.new

    ES_BODS_V2_INDEX = ENV.fetch('BODS_INDEX', 'bods_v2_psc1')
  end
end
