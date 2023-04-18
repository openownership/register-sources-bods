module RegisterSourcesBods
    module Register
        class Entity
            def initialize(statement)
                @statement = statement

                @master_entity = nil
                @merged_entities = []
                @relationships_as_source = []
                @relationships_as_target = []

                @resolver_response = nil
            end

            attr_reader :statement

            attr_accessor :relationships_as_source, :relationships_as_target, :master_entity, :merged_entities, :resolver_response

            # Mapping methods

            def address
                # ./app/views/shared/_entity_title.html.haml:        - entity.address.try do |address|
                statement.addresses&.first&.address
            end

            def company_number
                # ./app/controllers/entities_controller.rb:    client.get_company(entity.jurisdiction_code, entity.company_number, sparse: false)
                # ./app/views/entities/raw.html.haml:                - @entity.company_number.try do |company_number|
                # ./app/views/entities/_graph_tooltip.html.haml:      - entity.company_number.try do |company_number|
                # TODO: implement for other sources
                statement.identifiers.find { |ident| ident.scheme == "GB-COH" }&.id
            end

            def company_number?
                # ./app/controllers/entities_controller.rb:    return unless entity.jurisdiction_code? && entity.company_number?
                company_number.present?
            end

            def company_type
                # ./app/views/entities/raw.html.haml:                - @entity.company_type.try do |company_type|
            end

            def country
                # ./app/decorators/entity_graph_decorator.rb:        flag: h.country_flag_path(entity.country),
                # ./app/helpers/entity_helper.rb:    return unless (country = entity.country)
                # ./app/helpers/entity_helper.rb:      parts << entity.country.try(:nationality)
                # ./app/views/entities/_ultimate_source_relationship.html.haml:          = country_flag(entity.country)
                # ./app/views/entities/_ultimate_source_relationship.html.haml:        = country_flag(@entity.country)
                # ./app/views/shared/_entity_title.html.haml:        = country_flag(entity.country)
                # ./app/views/entities/_graph_tooltip_title.html.haml:    = country_flag(entity.country)
                # ./app/views/entities/raw.html.haml:                    = country_flag(@entity.country)
                # ./app/views/entities/raw.html.haml:                    = country_flag(@entity.country)
                # ./app/views/entities/raw.html.haml:                - @entity.country.try(:nationality).try do |nationality|
                country_code =
                    if statement.statementType == RegisterSourcesBods::StatementTypes['personStatement']
                        # TODO: Multiple supported but just reading first
                        statement&.nationalities&.first&.code
                    else
                        statement&.incorporatedInJurisdiction&.code 
                    end

                return unless country_code

                ISO3166::Country[country_code]
            end

            def country_subdivision
                # ./app/helpers/entity_helper.rb:    if entity.country_subdivision
                # ./app/helpers/entity_helper.rb:      "#{entity.country_subdivision.name} (#{country_label})"

                # TODO: subdivisions are ignored in BODS v0.2
                # Hack for now - use oc identifier if exists?
                nil
            end

            def country_of_residence
                # ./app/views/entities/raw.html.haml:                - @entity.country_of_residence.try do |country_of_residence|
            end

            def dissolution_date
                # ./app/decorators/entity_graph_decorator.rb:    entity = node.entity.decorate(context: context)
                # ./app/views/entities/_graph_tooltip.html.haml:      - entity.dissolution_date.try do |dissolution_date|
                statement.dissolutionDate
            end

            def dob
                # ./app/helpers/entity_helper.rb:    return unless entity.dob
                # ./app/helpers/entity_helper.rb:    parts << Date::MONTHNAMES[entity.dob.month] if entity.dob.atoms.size > 1
                # ./app/helpers/entity_helper.rb:    parts << entity.dob.year
                dob = statement.try(:birthDate)

                return unless dob

                ISO8601::Date.new(dob)
            end

            def id
                # ./app/controllers/relationships_controller.rb:    raise Mongoid::Errors::DocumentNotFound.new(Relationship, [target_entity.id, source_entity.id]) if relationships.empty?
                # ./app/models/entity_graph.rb:    return if seen.include?(entity.id.to_s)
                # ./app/models/entity_graph.rb:    seen.add entity.id.to_s
                # ./app/models/entity_graph.rb:      entity.id.to_s
                # ./app/models/entity_graph.rb:        @source_id = entity.id.to_s
                # ./app/models/entity_graph.rb:        @target_id = entity.id.to_s
                # ./app/models/unknown_persons_entity.rb:      id: "#{entity.id}#{Entity::UNKNOWN_ID_MODIFIER}",
                # ./app/models/unknown_persons_entity.rb:      id: "#{statement.entity.id}-statement-#{Digest::SHA256.hexdigest(statement.id.to_json)}",
                # ./app/decorators/entity_graph_decorator.rb:      selected: entity.id.to_s,
                # ./app/step_processing/calculate_relationships_as_target.rb:          entity.id.to_s
                # ./app/step_processing/calculate_relationships_as_source_v2.rb:          id = entity.id.to_s
                # ./app/step_processing/calculate_relationships_as_source.rb:          id = entity.id.to_s
                # ./app/step_processing/calculate_relationships_as_source.rb:          [entity.id.to_s, rs]
                # ./app/step_processing/calculate_relationships_as_source_v2.rb:          [entity.id.to_s, rs]
                # ./app/step_processing/calculate_relationships_as_source.rb:          id = entity.id.to_s
            end

            def identifiers
                # ./app/repositories/raw_data_record_repository.rb:    bods_identifiers = identifier_converter.convert_v1_to_v2 entity.identifiers
                # ./app/controllers/entities_controller.rb:      identifier_converter.convert_v1_to_v2(entity.identifiers)).first
                statement.identifiers
            end

            def incorporation_date
                # ./app/helpers/entity_helper.rb:      parts << "(#{entity.incorporation_date} – #{entity.dissolution_date})" if entity.incorporation_date?
                # ./app/views/entities/_graph_tooltip.html.haml:      - entity.incorporation_date.try do |incorporation_date|
                statement.foundingDate
            end

            def incorporation_date?
                # ./app/helpers/entity_helper.rb:      parts << "(#{entity.incorporation_date} – #{entity.dissolution_date})" if entity.incorporation_date?
                incorporation_date.present?
            end

            def jurisdiction_code
                # ./app/controllers/entities_controller.rb:    client.get_company(entity.jurisdiction_code, entity.company_number, sparse: false)
                return unless resolver_response

                jurisdiction_code = resolver_response.jurisdiction_code
                return unless jurisdiction_code
            
                code, = jurisdiction_code.split('_')
                country = ISO3166::Country[code]
                return nil if country.blank?

                RegisterSourcesBods::Jurisdiction.new(name: country.name, code: country.alpha2)

                statement&.incorporatedInJurisdiction&.code
            end

            def jurisdiction_code?
                # ./app/controllers/entities_controller.rb:    return unless entity.jurisdiction_code? && entity.company_number?
                jurisdiction_code.present?
            end

            def name
                # ./app/controllers/entities_controller.rb:      query: Search.query(q: entity.name, type: 'natural-person'),
                # ./app/decorators/entity_graph_decorator.rb:        label: entity.name,
                # ./app/views/entities/graph.html.haml:- content_for(:title, @entity.name)
                # ./app/views/entities/raw.html.haml:- content_for(:title, @entity.name)
                # ./app/views/entities/raw.html.haml:              %h1.entity-name= @entity.name
                # ./app/views/entities/_ultimate_source_relationship.html.haml:          = entity.name
                # ./app/views/entities/_ultimate_source_relationship.html.haml:          = @entity.name
                # ./app/views/entities/_graph_tooltip_title.html.haml:    = entity.name
                # ./app/views/shared/_entity_title.html.haml:      = entity.name
                # ./app/views/relationships/show.html.haml:- content_for(:title, [@source_entity.name, @target_entity.name].join(" → "))
                # ./app/views/relationships/show.html.haml:            = t(".title_html", source: render_haml("%span.entity-name.source= @source_entity.name"), target: render_haml("%span.entity-name= @target_entity.name"))
            end

            def natural_person?
                # ./app/controllers/entities_controller.rb:      @similar_people = entity.natural_person? ? decorate(similar_people(entity)) : nil
                # ./app/helpers/entity_helper.rb:    if entity.natural_person?
                # ./app/views/entities/_graph_tooltip_title.html.haml:  - if entity.natural_person?
                # ./app/views/shared/_entity_title.html.haml:      - if entity.natural_person?
                # ./app/views/entities/_graph_tooltip.html.haml:    - if entity.natural_person?
                return false unless statement

                statement.statementType == RegisterSourcesBods::StatementTypes['personStatement']
            end

            def self_updated_at
                # ./app/models/unknown_persons_entity.rb:      self_updated_at: entity.self_updated_at,
            end

            def type
                # ./app/views/entities/show.html.haml:              = t(".controlled_entities_none.#{@entity.type}_html", entity: render_haml("%span.entity-name= @sentity_name"))
                # ./app/views/entities/show.html.haml:              %p.unknown= t(".no_further_information_known", type: t("entity_types.#{@entity.type}", default: t("entity_types.default")))
                # ./app/step_processing/calculate_relationships_as_target.rb:          next unless entity && (entity.type != Structs::Entity::Types::NATURAL_PERSON)
                # ./app/step_processing/calculate_relationships_as_target_v2.rb:            elsif entity.type == Structs::Entity::Types::NATURAL_PERSON
                # ./app/step_processing/calculate_relationships_as_target.rb:            elsif entity.type == Structs::Entity::Types::NATURAL_PERSON
            end

            def unknown_reason
                # ./app/views/entities/_graph_tooltip_title.html.haml:    = entity.unknown_reason
                # ./app/views/entities/_graph_tooltip_title.html.haml:- if entity.respond_to?(:unknown_reason) && entity.unknown_reason
                # ./app/views/shared/_entity_title.html.haml:          = entity.unknown_reason
                # ./app/views/shared/_entity_title.html.haml:      - if entity.respond_to?(:unknown_reason) && entity.unknown_reason
            end

            # --------------
            # SOURCE SPECIFIC

            def from_denmark_cvr_v2?(statement)
                statement.identifiers.any? { |e| e.scheme == 'DK-CVR' }
            end

            # --------------
            # ASSOCIATIONS

            def merged_entities_count
                # ./app/views/entities/show.html.haml:                    = t(".merged_note_html", count: @entity.merged_entities_count, report_incorrect_data_url: report_incorrect_data_url)
                merged_entities.count
            end

            # --------------
            # TODO

            def todo_schema
                # ./app/views/entities/show.html.haml:  != @entity.schema
                # TODO: implement this in decorator?
            end

            def todo_cache_key
                # ./app/controllers/entities_controller.rb:        cache_key = "#{entity.cache_key}/bods_statements"
            end

            def todo_is_a
                # ./app/decorators/entity_graph_decorator.rb:    unless entity.is_a? UnknownPersonsEntity
                # ./app/helpers/entity_helper.rb:    if entity.is_a?(CircularOwnershipEntity) \
                # ./app/helpers/entity_helper.rb:      || entity.is_a?(UnknownPersonsEntity) \
            end

            def todo_decorate
                # ./app/decorators/entity_graph_decorator.rb:    entity = node.entity.decorate(context: context)
            end
        end
    end
end
