module Statik64
    module CLI
        class Putser

            attr_accessor :pastel,
                          :font

            HIGHLIGHT_COLOR = :yellow.freeze

            def initialize
                self.font = TTY::Font.new(:doom)
                self.pastel = Pastel.new
            end

            def get_detached_highlight_color
                self.pastel.public_send(HIGHLIGHT_COLOR).detach
            end

            def clear_terminal
                if Gem.win_platform?
                    system("cls")
                else
                     system("clear")
                end
                print "\e[2J\e[H"
            end

            def get_string_highlight(message)
                self.pastel.decorate(message, HIGHLIGHT_COLOR, :bold)
            end

            def get_string_bold(message)
                self.pastel.decorate(message, :bold)
            end

            def puts_bold(message)
                puts get_string_bold(message)
            end

            def puts_debug_mode
                puts get_string_bold("[DEBUG MODE]")
            end

            def puts_logo
                puts self.get_string_highlight(%q{
                                                    ____
   _____ __        __  _      __   _____ __ __     /   /
  / ___// /_____ _/ /_(_)____/ /__/ ___// // /    /_  /_
  \__ \/ __/ __ `/ __/ / ___/ //_/ __ \/ // /_     /  _/
 ___/ / /_/ /_/ / /_/ / /__/ ,< / /_/ /__  __/    / ,'
/____/\__/\__,_/\__/_/\___/_/|_|\____/  /_/      /'
                                              
            })
            end

            def puts_about_text
                puts ("""
#{self.get_string_highlight("Description")} : Statik64 est un CLI permettant de générer des APIs TypeScript
              en se basant sur les modèle définis dans ActiveRecord
#{self.get_string_highlight("Version")} :     #{Statik64::VERSION}
                """)
            end

        end
    end
end
