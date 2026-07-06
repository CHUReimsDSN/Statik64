module Statik64
	module CLI
		
		class FileWritter
			attr_accessor :export_list,
										 :content_segments,
										 :model_class,
										 :base_type_name,
										 :base_type_columns
			
			FILE_API_SEPARATOR = '-'.freeze
			FILE_API_EXTENSION = '.api.ts'.freeze
			FILE_API_INDENTATION_SPACE = 2.freeze
			FILE_API_BETWEEN_CONTENT_SEGMENT = "\n".freeze
			FILE_API_PATH = Rails.root # TODO
			TYPE_PREFIX = 'T'.freeze
			API_CONST_SUFFIX = 'Api'.freeze
			
			def initialize(model_class)
				self.export_list = []
				self.content_segments = []
				self.model_class = model_class
			end
			
			def get_filename_ts
				model_class.to_s
				.split('::')
				.map(&:downcase)
				.join(FILE_API_SEPARATOR)
				.concat(FILE_API_EXTENSION)
			end
			
			def add_base_type_ts(allow_enum = false, allow_relations = false)
				get_types_by_column = -> (column) {
					types = []
					case column.type
					when :integer
						types << 'number'
					when :decimal
						types << 'number'
					when :jsonb
						types << 'Record<string, unknown>'
					when :boolean
						types << 'boolean'
					else
						types << 'string'
					end
					if column.null
						types << 'null'
					end
					types.join(' | ')
				}
				columns_by_types = model_class.columns.map do |column|
					{
						name: column.name,
						types: get_types_by_column.call(column)
					}
				end
				base_type_name = "#{TYPE_PREFIX}#{model_class.model_name.name.camelcase}"
				content = []
				content << "export type #{base_type_name} = {"
				columns_by_types.each do |column|
					content << "#{add_indentation}#{column[:name]}: #{column[:types]};"
				end
				content << '}'
				base_type_name = base_type_name
				content_segments << content.join(FILE_API_BETWEEN_CONTENT_SEGMENT)
			end
			
			def add_enum_type_ts(enum_name)
				enum_found = model_class.defined_enums[enum_name]
				if enum_found.nil?
					raise
				end
				content = []
				content << "export type #{base_type_name}#{enum_name.camelcase} = "
				content << enum_found.keys.map {|k| "'#{k}'"}.join(' | ')
				content << ';'
				content_segments << content
			end
			
			def add_const_model_name_ts
				const_name = 'modelName'.freeze
				content_segments << "const #{const_name} = '#{model_class.model_name.name}';"
				export_list << const_name
			end
			
			def add_routes_rest_const_ts
				const_name = 'url'.freeze
				content_segments << "const #{const_name} = '#{model_class.model_name.route_key}';"
				export_list << const_name
			end

			def add_function_get_default
				function_name = 'getDefault'.freeze
				get_value_by_column = -> (column) {
					value = ''
					case column.type
					when :integer
						value = '0'
					when :decimal
						value = '0'
					when :jsonb
						value = '{}'
					when :boolean
						value = 'true'
					else
						value = ''
					end
					if column.null
						value = 'null'
					end
					if column.default != nil
						value = column.default
					end
					value
				}
				values_by_columns = model_class.columns.map do |column|
					{
						name: column.name,
						value: get_value_by_column.call(column)
					}
				end
				content = []
				content << "function #{function_name}(): Partial<#{base_type}> {"
				values_by_columns.each do |value|
					content << "#{add_indentation}#{value[:name]}: #{value[:value]},"
				end
				content << "}"
				content_segments << content.join(FILE_API_BETWEEN_CONTENT_SEGMENT)
				export_list << function_name
			end

			def add_function_enum(enum_name)
				enum_found = model_class.defined_enums[enum_name]
				if enum_found.nil?
					raise
				end
				function_name = "get#{enum_name.camelcase}Options"
				content = []
				content << "function #{function_name}() {"
				content << "#{add_indentation}return ["
				content << enum_found.keys.map {|k| "#{add_indentation(2)}'#{k}'"}.join(' , ')
				content << "#{add_indentation}];"
				content << '}'
				content_segments << content.join(FILE_API_BETWEEN_CONTENT_SEGMENT)
				export_list << function_name
			end

			def add_function_rest(route)
				function_name = route[:action_name].camelize
				content = []
				content << "async function #{function_name}(): Promise {"
				content << "#{add_indentation}return"
				# TODO
				content << '}'
				content_segments << content.join(FILE_API_BETWEEN_CONTENT_SEGMENT)
				export_list << function_name
			end
			
			def add_const_export_ts
				content = []
				content << "export const #{}#{API_CONST_SUFFIX} = {"
				export_list.each do |export_segment|
					content << "#{add_indentation}#{export_segment},"
				end
				content << "}"
				content_segments << content.join(FILE_API_BETWEEN_CONTENT_SEGMENT)
			end
			
			def add_indentation(occurence = 1)
				content = ''
				occurence.times do
					FILE_API_INDENTATION_SPACE.times do
						content << ' '
					end
				end
				content
			end

			def write_file
				if export_list.any?
					add_const_export_ts
				end
				content = content_segments.join("#{FILE_API_BETWEEN_CONTENT_SEGMENT}#{FILE_API_BETWEEN_CONTENT_SEGMENT}")
				# get_filename_ts
				File.write('test.ts', content)
			end
			
		end
	end
end