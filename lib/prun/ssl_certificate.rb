# frozen_string_literal: true

class SslCertificate
  DNS_PROVIDER = 'digitalocean'
  NGINX_RELOAD_COMMAND = 'service nginx restart'
  CREDENTIALS_PATH = '/etc/letsencrypt/digitalocean.ini'
  DOMAIN = "#{`hostname`.strip}.com".freeze

  def self.renew = new.renew

  def renew
    create_credentials_file
    if run_command(certbot_command)
      Rails.logger.info "SSL::Certificate renewed successfully for #{DOMAIN}."
      if run_command(NGINX_RELOAD_COMMAND)
        Rails.logger.info 'SSL::Web server reloaded.'
      else
        Rails.logger.fail 'SSL::Failed to reload web server.'
      end
    else
      Rails.logger.fail "SSL::Certificate renewal failed for #{DOMAIN}."
    end
    remove_credentials_file
  end

  private

  def certbot_command
    'certbot certonly ' \
      "--dns-#{DNS_PROVIDER} " \
      "--dns-#{DNS_PROVIDER}-credentials #{CREDENTIALS_PATH} " \
      "-d '*.#{DOMAIN}' " \
      "-d '#{DOMAIN}' " \
      '--agree-tos ' \
      '--no-eff-email ' \
      "--email admin@#{DOMAIN} " \
      '--force-renewal'
  end

  def create_credentials_file
    `DEBIAN_FRONTEND=noninteractive apt install -y python3-certbot-dns-digitalocean`
    File.write(CREDENTIALS_PATH, "dns_#{DNS_PROVIDER}_token=#{Cred[:dns_digitalocean_token]}")
    File.chmod(0o600, CREDENTIALS_PATH)
    Rails.logger.info "SSL::Credentials file created at #{CREDENTIALS_PATH}."
  end

  def remove_credentials_file
    File.delete(CREDENTIALS_PATH) if File.exist?(CREDENTIALS_PATH)
    Rails.logger.info "SSL::Credentials file removed from #{CREDENTIALS_PATH}."
  rescue Errno::ENOENT
    Rails.logger.warn "SSL::Credentials file not found at #{CREDENTIALS_PATH}."
  rescue StandardError => e
    Rails.logger.error "SSL::Error removing credentials file: #{e.message}"
  end

  def run_command(command)
    Rails.logger.info "SSL::Running: #{command}"
    output = `#{command} 2>&1`
    success = $CHILD_STATUS.success?

    Rails.logger.info("SSL::Output:\n#{output}") unless output.strip.empty?
    Rails.logger.fail("SSL::Command failed with exit status: #{$CHILD_STATUS.exitstatus}") unless success

    success
  end
end
