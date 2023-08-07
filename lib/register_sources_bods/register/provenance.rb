module RegisterSourcesBods
  module Register
    class Provenance
      MAPPINGS = {
        'GB Persons Of Significant Control Register' => 'UK PSC Register',
        'DK Centrale Virksomhedsregister' => 'Denmark Central Business Register (Centrale Virksomhedsregister [CVR])',
        'SK Register Partnerov Verejného Sektora' => 'Slovakia Public Sector Partners Register (Register partnerov verejného sektora)'
      }

      def initialize(bods_statement)
        @bods_statement = bods_statement
      end

      attr_reader :bods_statement

      def source_url
        bods_statement&.source&.url
      end

      def source_name
        name = bods_statement&.source&.description
        MAPPINGS[name] || name
      end

      def retrieved_at
        bods_statement&.source&.retrievedAt
      end

      def imported_at
        bods_statement&.source&.retrievedAt
      end
    end
  end
end
