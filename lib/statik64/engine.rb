module Statik64
    class Engine < Rails::Engine
        rake_tasks do
            load File.expand_path('tasks/statik64_tasks.rake', __dir__)
        end
    end
end