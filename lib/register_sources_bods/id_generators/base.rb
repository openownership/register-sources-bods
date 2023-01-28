require 'xxhash'

module RegisterSourcesBods
  module IdGenerators
    class Base
      # def generate_id(record)

      private

      def generate_statement_id(attributes)
        XXhash.xxh64(attributes).to_s
      end
  end
end
