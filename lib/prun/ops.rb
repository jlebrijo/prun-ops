# frozen_string_literal: true

require_relative "ops/version"
require_relative "cred"

module Prun
  module Ops
    class Error < StandardError; end
    # Your code goes here...
    require "prun/ops/railitie" if defined?(Rails)

    Rails.logger = Logger.new($stdout) if defined?(Rails) && (Rails.env == "development")
  end
end
