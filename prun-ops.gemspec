# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'prun-ops/version'

Gem::Specification.new do |spec|
  spec.name          = "prun-ops"
  spec.version       = PrunOps::VERSION
  spec.authors       = ["Juan Lebrijo"]
  spec.email         = ["juan@lebrijo.com"]
  spec.summary       = %q{Encapsulates Deployment and Manteinance Operations commands needed for a Rails Application.}
  spec.description   = %q{Encapsulates Operations commands for Rails Applications: Deploy, Diagnose, Monitoring, Version Releasing and Backup.}
  spec.homepage      = "http://github.com/jlebrijo/prun-ops"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"

  spec.add_runtime_dependency 'capistrano'
  spec.add_runtime_dependency 'capistrano-rails'
  spec.add_runtime_dependency 'capistrano-rvm'
  spec.add_runtime_dependency 'capistrano3-puma'
  spec.add_runtime_dependency 'thin'
  spec.add_runtime_dependency 'newrelic_rpm'
end
