Dir.glob("#{File.dirname(__FILE__)}/*.rake").each { |r| load r }
Dir.glob("#{File.dirname(__FILE__)}/config/*.rake").each { |r| load r }

## Common libraries
def template(template_name, target_path)
  begin
    file = File.read("#{File.dirname(__FILE__)}/config/templates/#{template_name}.erb")
  rescue
    file = File.read("lib/capistrano/config/templates/#{template_name}.erb")
  end

  template = ERB.new file, nil, "%"
  rendered = template.result(binding)
  tmp_file = "/tmp/#{SecureRandom.hex}.#{template_name}"
  upload! StringIO.new(rendered), tmp_file
  execute "sudo cp #{tmp_file} #{target_path}"
  execute  "rm #{tmp_file}"
end

## Bastion config
def bastion(host, user:)
  require 'net/ssh/proxy/command'
  ssh_command = "ssh -W %h:%p -o StrictHostKeyChecking=no #{user}@#{host}"
  set :ssh_options, proxy: Net::SSH::Proxy::Command.new(ssh_command)
end

def apt_nointeractive
  'sudo DEBIAN_FRONTEND=noninteractive apt-get install -y'
end