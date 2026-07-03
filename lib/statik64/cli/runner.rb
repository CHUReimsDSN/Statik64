require "tty-prompt"
require "tty-font"
require "pastel"

module Statik64
    module CLI
        class Runner

            attr_reader :menu_manager

            def self.boot
                self.new
            end

            private
            def initialize
                self.menu_manager = Statik64::CLI::MenuManager.new(self)
                nil
            end

        end
    end
end
