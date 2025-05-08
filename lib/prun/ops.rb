# frozen_string_literal: true

require_relative "ops/version"
require_relative 'cred'

module Prun
  module Ops
    class Error < StandardError; end
    # Your code goes here...
    require 'prun/ops/railitie' if defined?(Rails)

    if defined?(Rails) && (Rails.env == 'development')
      Rails.logger = Logger.new(STDOUT)
    end
  end
end
