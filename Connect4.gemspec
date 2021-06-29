# frozen_string_literal: true

require_relative "lib/Connect4/version"

Gem::Specification.new do |spec|
  spec.name          = "Connect4"
  spec.version       = Connect4::VERSION
  spec.authors       = ["Alex Pike"]
  spec.email         = ["55725286+theRamenWithin@users.noreply.github.com"]

  spec.summary       = "Connect4 coding assignment for GlamCorner"
  spec.description   = "A small Connect4 game written in ruby. Play against an AI or your friends."
  spec.homepage      = "https://www.alexpike.work"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.4.0")

  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/theRamenWithin/Connect4"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
