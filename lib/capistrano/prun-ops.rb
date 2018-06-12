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
