namespace :nodejs do
  task :install do
    on roles :app do
      execute 'curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.8/install.sh | bash'
      #sed -i "s/[ -z "$PS1" ] && return/# [ -z "$PS1" ] && return/g" /root/.bashrc
      execute <<-EOBLOCK
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        nvm install node
        npm install -g bower
      EOBLOCK
    end
  end
end