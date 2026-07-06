module Statik64
    module CLI
        class MenuManager

            attr_accessor :prompt,
                          :putser,
                          :current_menu_data,
                          :actions_pool,
                          :debug_mode

            MENU_HOME_NAME = :home.freeze
            MENU_PICK_SINGLE_NAME = :pick_single.freeze
            MENU_GENERATE_SINGLE_NAME = :generate_single.freeze
            MENU_DONE_NAME = :done.freeze
            MENU_GENERATE_UTILS_NAME = :generate_utils.freeze
            MENU_ABOUT_NAME = :about.freeze

            def initialize(runner)
                self.debug_mode = true
                self.actions_pool = []
                self.putser = Statik64::CLI::Putser.new
                self.prompt = TTY::Prompt.new(active_color: self.putser.get_detached_highlight_color)
                self.current_menu_data = {
                    current_menu_name: MENU_HOME_NAME,
                    previous_menu_name: nil,
                    context: {
                        selected_model: nil,
                        message: nil
                    }
                }
                
                run_menu(MENU_HOME_NAME)
                while self.actions_pool.any?
                    first_action = self.actions_pool.first
                    self.actions_pool.shift
                    first_action.call
                end
                nil
            end

            private

            def add_action(action_proc)
                self.actions_pool << action_proc
            end

            def run_menu(name, context=nil)
                self.current_menu_data[:previous_menu_name] = self.current_menu_data[:current_menu_name]
                self.current_menu_data[:current_menu_name] = name
                if context
                    self.current_menu_data[:context] = context
                end
                if self.debug_mode
                    self.putser.puts_debug_mode
                else
                    self.putser.clear_terminal
                end
                self.putser.puts_logo
                case name
                when MENU_HOME_NAME
                    run_home_menu
                when MENU_PICK_SINGLE_NAME
                    run_pick_single_menu
                when MENU_GENERATE_SINGLE_NAME
                    run_generate_single_menu
                when MENU_GENERATE_UTILS_NAME
                    run_generate_utils_menu
                when MENU_DONE_NAME
                    run_done_menu
                when MENU_ABOUT_NAME
                    run_about_menu
                else
                    raise
                end
            end

            def leave
                self.putser.clear_terminal
                self.actions_pool.clear
                nil
            end

            def get_go_back_option
                {
                    label: 'Retour',
                    action: -> { run_menu(self.current_menu_data[:previous_menu_name]) }
                }
            end

            def get_go_home_option
                {
                    label: 'Retour',
                    action: -> { run_menu(MENU_HOME_NAME) }
                }
            end

            def run_home_menu
                definition = {
                    title: 'Menu principal',
                    options: [
                        {
                            label: 'Génération par modèle',
                            action: -> { run_menu(MENU_PICK_SINGLE_NAME) }
                        },
                        {
                            label: "Génération d'utilitaires",
                            action: -> { run_menu(MENU_GENERATE_UTILS_NAME) }
                        },
                        {
                            label: 'A propos',
                            action: -> { run_menu(MENU_ABOUT_NAME) }
                        },
                        {
                            label: 'Quitter',
                            action: -> { leave }
                        }
                    ]
                }
                response = self.prompt.select(
                    self.putser.get_string_bold("#{definition[:title]} \n"),
                    show_help: :never
                ) do |menu|
                    definition[:options].each do |option|
                        menu.choice(option[:label])
                    end
                end
                option_found = definition[:options].find {|option| option[:label] == response}
                if option_found.nil?
                    raise
                end
                add_action(option_found[:action])
            end

            def run_pick_single_menu
                options = [get_go_back_option]
                Statik64::CLI::RecordManager.get_model_list.each do |model|
                    context = {
                        selected_model: model
                    }
                    options << {
                        label: model.to_s,
                        action: -> { run_menu(MENU_GENERATE_SINGLE_NAME, context ) }
                    }
                end
                definition = {
                    title: 'Sélectionnez un modèle',
                    options: options
                }
                response = self.prompt.select(
                    self.putser.get_string_bold("#{definition[:title]} \n"),
                    show_help: :never
                ) do |menu|
                    definition[:options].each do |option|
                        menu.choice(option[:label])
                    end
                end
                option_found = definition[:options].find {|option| option[:label] == response}
                if option_found.nil?
                    raise
                end
                add_action(option_found[:action])
            end

            def run_generate_single_menu
                model_class = self.current_menu_data[:context][:selected_model]
                if model_class == nil
                    raise
                end
                record_manager = Statik64::CLI::RecordManager.new(model_class)
                options = record_manager.get_menu_options
                definition = {
                    title: "Que désirez-vous ? (#{model_class.to_s})",
                    options: options
                }
                response = self.prompt.multi_select(
                    self.putser.get_string_bold("#{definition[:title]} \n"),
                    show_help: :never,
                    echo: false
                ) do |menu|
                    definition[:options].each do |option|
                        menu.choice(option[:label])
                    end
                end
                if response.any?
                    filename = record_manager.write_api_file(response)
                    add_action(-> { run_menu(MENU_DONE_NAME, {
                        message: "Terminé ! Fichier généré #{filename}"
                    }) })
                else
                    add_action(get_go_back_option[:action])
                end
            end

            def run_done_menu
                definition = {
                    title: self.current_menu_data[:context][:message],
                    options: [get_go_home_option]
                }
                response = self.prompt.select(
                    self.putser.get_string_bold("#{definition[:title]} \n"),
                    show_help: :never
                ) do |menu|
                    definition[:options].each do |option|
                        menu.choice(option[:label])
                    end
                end
                option_found = definition[:options].find {|option| option[:label] == response}
                if option_found.nil?
                    raise
                end
                add_action(option_found[:action])
            end

            def run_generate_utils_menu
            # TODO 
            end

            def run_about_menu
                self.putser.puts_about_text
                definition = {
                    title: '',
                    options: [get_go_back_option]
                }
                response = self.prompt.select(
                    self.putser.get_string_bold("#{definition[:title]} \n"),
                    show_help: :never
                ) do |menu|
                    definition[:options].each do |option|
                        menu.choice(option[:label])
                    end
                end
                option_found = definition[:options].find {|option| option[:label] == response}
                if option_found.nil?
                    raise
                end
                add_action(option_found[:action])
            end

        end
    end
end
