# frozen_string_literal: true

require_relative "lib/statik64/version"

Gem::Specification.new do |spec|
  spec.name = "statik64"
  spec.version = Statik64::VERSION
  spec.authors = ["Jules Debeaumont"]
  spec.email = ["jdebeaumont@chu-reims.fr"]

  spec.summary = "Tool for generating TypeScript Api"
  spec.description = "Tool for generating TypeScript Api"
  spec.homepage = "https://github.com/CHUReimsDSN/Statik64-Rails"
  spec.required_ruby_version = ">= 2.6.0"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "activerecord", ">= 6.0"
  spec.add_dependency "tty-prompt"
  spec.add_dependency "tty-progressbar"
  spec.add_dependency "tty-font"
  spec.add_dependency "pastel"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
