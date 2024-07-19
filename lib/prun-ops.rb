require "prun-ops/version"
require "cred"

module PrunOps
  require 'prun-ops/railitie' if defined?(Rails)

  if defined?(Rails) && (Rails.env == 'development')
    Rails.logger = Logger.new(STDOUT)
  end
end
