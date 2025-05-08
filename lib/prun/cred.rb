# frozen_string_literal: true

class Cred
  def self.[](name)
    env_result = Rails.application.credentials.dig(Rails.env.to_sym, name)
    return Rails.application.credentials[name] unless env_result

    env_result
  end
end
