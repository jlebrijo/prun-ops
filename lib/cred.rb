class Cred
  def self.[](name)
    env_result = Rails.application.credentials.dig(Rails.env.to_sym, name)
    return Rails.application.credentials.dig(name) unless env_result
    env_result
  end
end