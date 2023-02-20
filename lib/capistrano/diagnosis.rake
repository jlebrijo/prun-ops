desc 'SSH connection with server'
task :ssh do
  on roles(:app) do |host|
    run_locally do
      run_in host, ""
    end
  end
end

desc 'Opens a remote Rails console'
task :c do
  on roles(:app) do |host|
    run_locally do
      run_in host, "cd #{current_path} && RAILS_ENV=#{fetch(:stage)} bundle exec rails c"
    end
  end
end

desc 'Opens a remote Database console'
task :dbconsole do
  on roles(:app) do |host|
    run_locally do
      run_in host, "cd #{current_path} && RAILS_ENV=#{fetch(:stage)} bundle exec rails dbconsole --include-password"
    end
  end
end

desc 'Tails the environment log or the log passed as argument: cap log_tail[thin.3000.log]'
task :log_tail, :file do |task, args|
  on roles(:app) do
    file = args[:file]? args[:file] : "*"
    execute "tail -f #{current_path}/log/#{file} | grep -vE \"(^\s*$|asset|Render)\""
  end
end

desc 'Search for a pattern in logs'
task :log_pattern, :pattern do |task, args|
  on roles(:app) do
    execute "cat #{current_path}/log/* | grep -A 10 -B 5 '#{args[:pattern]}'"
  end
end

desc "Runs a command in server: cap production x['free -m']"
task :x, :command do |task, args|
  on roles(:app) do |host|
    run_locally do
      run_in host, args[:command]
    end
  end
end

desc 'Executes a rake task in server. i.e.: cap staging rake[db:version]'
task :rake, :remote_task do |task, args|
  on roles(:app) do
    within release_path do
      with rails_env: fetch(:stage) do
        execute :rake, "#{args[:remote_task]}"
      end
    end
  end
end

desc 'Uploads a file to /tmp folder. i.e.: cap staging upload[tmp/db.sql]'
task :upload, :file_path do |task, args|
  on roles(:app) do |host|
    run_locally do
      upload_scp host, args[:file_path]
    end
  end
end

desc 'Downloads a file. i.e.: cap staging download[/tmp/db.sql]'
task :download, :file_path do |task, args|
  on roles(:app) do |host|
    run_locally do
      download_scp host, args[:file_path]
    end
  end
end


def run_in(host, remote_cmd)
  cmd = %w[ssh]
  opts = fetch(:ssh_options)
  cmd << "-oProxyCommand='#{opts[:proxy].command_line_template}'" if opts
  cmd << "#{host.user}@#{host.hostname}"
  cmd << "-p #{host.port || '22'}"
  cmd << "-tt '#{remote_cmd}'"

  command = cmd.join(' ')
  Rails.logger.info command
  exec command
end

def upload_scp(host, file_path)
  cmd = %w[scp]
  opts = fetch(:ssh_options)
  cmd << "-r -o StrictHostKeyChecking=no"
  cmd << "-oProxyCommand='#{opts[:proxy].command_line_template}'" if opts
  cmd << file_path
  cmd << "#{host.user}@#{host.hostname}:/tmp"

  command = cmd.join(' ')
  Rails.logger.info command
  exec command
end

def download_scp(host, file_path)
  cmd = %w[scp]
  opts = fetch(:ssh_options)
  cmd << "-oProxyCommand='#{opts[:proxy].command_line_template}'" if opts
  cmd << "#{host.user}@#{host.hostname}:#{file_path}"
  cmd << '.'

  command = cmd.join(' ')
  Rails.logger.info command
  exec command
end

