namespace :ruby do
  task :install do
    ruby_version = File.read('.ruby-version').strip[/\Aruby-(.*)\.\d\Z/,1]
    on roles :all do
      execute <<-EOBLOCK
        sudo apt-add-repository -y ppa:brightbox/ruby-ng
        apt-get update
        sudo apt-get install -y ruby#{ruby_version} ruby#{ruby_version}-dev
      EOBLOCK
    end
  end
end
