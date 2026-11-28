# frozen_string_literal: true

class App
  def self.[](name)
    Rails.application.config_for(:application).fetch(name.to_sym)
  end
end
