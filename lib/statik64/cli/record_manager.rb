module Statik64
    module CLI
        class RecordManager

            attr_accessor :model_class

            OPTION_BASE_TYPE = 'base_type'.freeze
            OPTION_CONST_MODEL_NAME = 'constant_model_name'.freeze
            OPTION_FUNCTION_GET_DEFAULT = 'function_get_default'.freeze
            OPTION_TYPE_ENUM_SEGMENT = 'type_for_enum_'.freeze
            OPTION_FUNCTION_ENUM_SEGMENT = 'function_display_for_enum'.freeze
            OPTION_FUNCTION_REST_SEGMENT = 'function_rest_'.freeze

            MODEL_TO_EXCLUDE = [
                'ActionText::RichText',
                'ActionText::EncryptedRichText',
                'ActiveStorage::VariantRecord',
                'ActiveStorage::Blob',
                'ActiveStorage::Attachment',
                'ActionMailbox::InboundEmail'
            ].freeze

            def initialize(model_class)
                self.model_class = model_class
            end

            def get_menu_options
                options = []
                options << {
                    label: 'Type typescript',
                    value: OPTION_BASE_TYPE,
                }
                options << {
                    label: 'Constante nom du modèle',
                    value: OPTION_CONST_MODEL_NAME
                }
                enums = model_class.defined_enums
                if enums.any?
                    model_class.defined_enums.keys.each do |enum_name|
                        options << {
                            label: "Type pour enum '#{enum_name}'",
                            value: "#{OPTION_TYPE_ENUM_SEGMENT}#{enum_name}"
                        }
                        options << {
                            label: "Fonction affichage pour enum '#{enum_name}'",
                            value: "#{OPTION_FUNCTION_ENUM_SEGMENT}#{enum_name}"
                        }
                    end
                end
                routes = get_routes
                if routes.any?
                    routes.each do |route|
                        options << {
                            label: "Fonction REST #{route[:composite_key]}",
                            value: "#{OPTION_FUNCTION_REST_SEGMENT}#{route[:composite_key]}"
                        }
                    end
                end
                options << {
                    label: 'Fonction getDefault',
                    value: OPTION_FUNCTION_GET_DEFAULT
                }
                options
            end

            def get_routes
                RecordManager.route_list.select do |route|
                    [
                        model_class.model_name.route_key,
                        model_class.model_name.route_key.singularize,
                    ].include?(route[:model_route_key])
                end
            end

            def write_api_file(option_values)
                writter = Statik64::CLI::RecordWritter.new(self.model_class)
                option_values.each do |value|
                    case value
                    when OPTION_BASE_TYPE
                        writter.add_base_type_ts
                        next
                    when OPTION_CONST_MODEL_NAME
                        writter.add_const_model_name_ts
                        next
                    when OPTION_FUNCTION_GET_DEFAULT
                        writter.add_function_get_default
                        next
                    end
                    if value.include?(OPTION_TYPE_ENUM_SEGMENT)
                        enum_name = value.gsub(OPTION_TYPE_ENUM_SEGMENT, '')
                        writter.add_enum_type_ts(enum_name)
                        next
                    end
                    if value.include?(OPTION_FUNCTION_ENUM_SEGMENT)
                        enum_name = value.gsub(OPTION_FUNCTION_ENUM_SEGMENT, '')
                        writter.add_function_enum(enum_name)
                        next
                    end
                    if value.include?(OPTION_FUNCTION_REST_SEGMENT)
                        route = get_routes.find do |route|
                            route[:composite_key] == value.gsub(OPTION_FUNCTION_REST_SEGMENT, '')
                        end
                        if route.nil?
                            raise
                        end
                        writter.add_function_rest(route)
                        next
                    end
                end
                writter.write_file
                writter.get_filename_ts
            end
            
            def self.get_model_list
                ActiveRecord::Base.descendants.filter do |model|
                    MODEL_TO_EXCLUDE.exclude?(model.to_s) && !model.abstract_class?
                end
            end

            def self.route_list
                Rails.application.routes.routes.map do |route|
                    {
                        model_route_key: route.defaults[:controller],
                        path_segments: route.path.spec.to_s.gsub('(.:format)', '').split('/').filter {|segment| segment != 'api' && !segment.empty?},
                        method_http: route.verb,
                        action_name: route.defaults[:action],
                        composite_key: "#{route.defaults[:controller]}##{route.defaults[:action]}"
                    }
                end.filter do |route|
                    route[:action_name] != nil
                end
            end
        end
    end
end