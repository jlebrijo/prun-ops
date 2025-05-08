namespace :nodejs do
  task :install do
    on roles :app do
      execute 'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash'

      execute <<-EOBLOCK
        export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
      EOBLOCK
      execute '{ tail -n 3 .bashrc && head -n -3 .bashrc; } > tempfile && mv tempfile .bashrc'

      execute <<-EOBLOCK
        nvm install node
        npm install -g yarn
      EOBLOCK

    end
  end
end