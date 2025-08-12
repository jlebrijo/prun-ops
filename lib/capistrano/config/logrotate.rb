# frozen_string_literal: true

namespace :logrotate do
  task :install do
    on roles :all do
      command "#{apt_nointeractive} logrotate ncdu"
      script = <<-TEXT
        /var/www/mx/shared/log/*.log {
          daily
          missingok
          rotate 7
          compress
          delaycompress
          notifempty
          create 0664 root root
        }
      TEXT
      upload! StringIO.new(script), '/tmp/mx'
      execute 'mv /tmp/mx /etc/logrotate.d/mx'
    end
  end
end
