namespace :statik64 do
  desc "Launch Statik64 CLI"
  task run: :environment do
    Statik64::CLI::Runner.boot
  end
end
