# frozen_string_literal: true

require_relative "lib/prun/ops/version"

Gem::Specification.new do |spec|
  spec.name = "prun-ops"
  spec.version = Prun::Ops::VERSION
  spec.authors = ["jlebrijo"]
  spec.email = ["jlebrijo@gmail.com"]

  spec.summary       = "Encapsulates Deployment and Manteinance Operations commands needed for a Rails Application."
  spec.description   = "Encapsulates Operations commands for Rails Applications: Deploy, Diagnose, Monitoring, Version Releasing and Backup."
  spec.homepage      = "http://github.com/jlebrijo/prun-ops"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"
  spec.add_dependency "capistrano"
  spec.add_dependency "capistrano3-puma"
  spec.add_dependency "capistrano-rails"
  spec.add_dependency "capistrano-rvm"
  spec.add_dependency "newrelic_rpm"
  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
  spec.metadata["rubygems_mfa_required"] = "true"
end
