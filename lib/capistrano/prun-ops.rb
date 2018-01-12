Dir.glob("#{File.dirname(__FILE__)}/*.rake").each { |r| load r }
Dir.glob("#{File.dirname(__FILE__)}/config/*.rake").each { |r| load r }

## Common libraries
def template(template_name, target_path)
  file = File.read("#{File.dirname(__FILE__)}/config/templates/#{template_name}.erb")
  template = ERB.new file, nil, "%"
  rendered = template.result(binding)
  upload! StringIO.new(rendered), target_path
end
