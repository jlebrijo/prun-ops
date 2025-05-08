namespace :ruby do
  task :brightbox do
    ruby_version = File.read('.ruby-version').strip[/\Aruby-(.*)\.\d\Z/,1]
    on roles :all do
      execute <<-EOBLOCK
        sudo apt-add-repository -y ppa:brightbox/ruby-ng
        sudo apt-get update
        #{apt_nointeractive}  ruby#{ruby_version} ruby#{ruby_version}-dev
      EOBLOCK
    end
  end
  task :rvm do
    on roles :all do
      execute <<-EOBLOCK
      sudo apt-add-repository -y ppa:rael-gc/rvm
      sudo apt-get update
      #{apt_nointeractive} rvm
      sudo usermod -a -G rvm $USER
      cp ~/.bashrc ~/.bashrc.bak
      { echo '[[ -s /usr/share/rvm/scripts/rvm ]] && source /usr/share/rvm/scripts/rvm'; cat ~/.bashrc.bak; } > ~/.bashrc
      EOBLOCK
    end
  end
  task :install_rvm_project_version do
    ruby_version = File.read('.ruby-version').strip
    ruby_version = ruby_version.start_with?('ruby-') ? ruby_version : "ruby-#{ruby_version}"

    on roles :all do
      execute <<-EOBLOCK
      source "/etc/profile.d/rvm.sh"
      rvm install #{ruby_version}
      rvm --default use #{ruby_version}
      EOBLOCK
    end
  end

end
