module Statik64
	module CLI
		
		class FileWritter
			attr_accessor :export_list,
										 :content_segments,
										 :model_class,
										 :base_type_name,
										 :import_list,
										 :url_list
			
			FILE_API_SEPARATOR = '-'.freeze
			FILE_API_EXTENSION = '.api.ts'.freeze
			FILE_API_INDENTATION_SPACE = 2.freeze
			FILE_API_BETWEEN_CONTENT_SEGMENT = "\n".freeze
			FILE_API_PATH = Rails.root # TODO
			TYPE_PREFIX = 'T'.freeze
			API_CONST_SUFFIX = 'Api'.freeze
			AXIOS_IMPORT = "import { api } from 'boot/axios';"
			
			def initialize(model_class)
				self.export_list = []
				self.content_segments = []
				self.model_class = model_class
				self.base_type_name = ''
				self.import_list = []
				self.url_list = []
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
				self.base_type_name = "#{TYPE_PREFIX}#{model_class.model_name.name.camelcase}"
				content = []
				content << "export type #{self.base_type_name} = {"
				columns_by_types.each do |column|
					content << "#{add_indentation}#{column[:name]}: #{column[:types]};"
				end
				content << '}'
				content_segments << content.join(FILE_API_BETWEEN_CONTENT_SEGMENT)
			end
			
			def add_enum_type_ts(enum_name)
				enum_found = model_class.defined_enums[enum_name]
				if enum_found.nil?
					raise
				end
				content = []
				content << "export type #{self.base_type_name}#{enum_name.camelcase} = "
				content << enum_found.keys.map {|k| "'#{k}'"}.join(' | ')
				content << ';'
				content_segments << content
			end
			
			def add_const_model_name_ts
				const_name = 'modelName'.freeze
				content_segments << "const #{const_name} = '#{model_class.model_name.name}';"
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
						value = "''"
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
				content << "function #{function_name}(): Partial<#{self.base_type_name}> {"
				content << "#{add_indentation}return {"
				values_by_columns.each do |value|
					content << "#{add_indentation(2)}#{value[:name]}: #{value[:value]},"
				end
				content << "#{add_indentation}}"
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
				ensure_axios_is_imported
				ensure_const_route_is_defined(route)
				function_name = route[:action_name].camelize(:lower)
				function_args = {}
				route[:path_segments].each do |segment|
					function_args[segment.camelize(:lower)] = "#{segment.include?('id') ? 'number' : 'string'}"
				end
				api_method = {
					'GET': 'get',
					'POST': 'post',
					'PUT': 'put',
					'PATCH': 'patch',
					'DELETE': 'delete'
				}[route[:method_http]] || 'get'
				url_segments = ['${url}']
				route[:path_segments].each do |segment|
					url_segments << "#{segment.include?(':') ? "${#{segment.camelize(:lower)}}" : segment}"
				end
				if ['get', 'delete'].exclude?(api_method)
					function_args["payload"] = "unknown"
				end
				function_args_string = function_args.entries.map do |entry|
					"#{entry[0]}: #{entry[1]}"
				end.join(', ')
				payload_arg_string = function_args["payload"].nil ? '' : ", { payload }"
				config_arg_string = ''
				content = []
				content << "async function #{function_name}(#{function_args}) {"
				content << "#{add_indentation}return (await api.#{api_method}(`#{url_segment.join('/')}`#{payload_arg_string}#{config_arg_string})).data;"
				content << '}'
				content_segments << content.join(FILE_API_BETWEEN_CONTENT_SEGMENT)
				export_list << function_name
			end
			
			def add_const_export_ts
				content = []
				content << "export const #{model_class.model_name.name.camelcase}#{API_CONST_SUFFIX} = {"
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

			def add_statik64_annotation
# 				~<<TEXT
# /**
#  * @generated_by_statik64
#  */
# 				TEXT
			end

			def ensure_axios_is_imported
				if self.import_list.exclude?(AXIOS_IMPORT)
					self.import_list << AXIOS_IMPORT
				end
				nil
			end

			def ensure_const_route_is_defined(route)
				first_segment = route[:path_segments].first
				if self.url_list.exclude?(first_segment)
					self.url_list << first_segment
					const_name = "url#{self.url_list.count == 1 ? '' : "#{self.url_list.count - 1}"}".freeze
					content_segments << "const #{const_name} = '#{first_segment}';"
					self.export_list << const_name
				end
				nil
			end

			def write_file
				content = ''
				if import_list.any?
					content << import_list.join(FILE_API_BETWEEN_CONTENT_SEGMENT)
					content << FILE_API_BETWEEN_CONTENT_SEGMENT
				end
				if export_list.any?
					add_const_export_ts
				end
				content << content_segments.join("#{FILE_API_BETWEEN_CONTENT_SEGMENT}#{FILE_API_BETWEEN_CONTENT_SEGMENT}")
				# get_filename_ts
				File.write('debug.ts', content)
			end
			
		end
	end
end
