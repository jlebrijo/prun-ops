# frozen_string_literal: true

namespace :yarn do
  task :install do
    on roles :app do
      execute <<-EOBLOCK
        curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
             echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
        apt-get -qq update && apt-get install -y yarn
      EOBLOCK
    end
  end

  task :dependencies do
    on roles :app do
      within release_path do
        execute :yarn, "install --check-files --frozen-lockfile --production=true"
      end
    end
  end
end

before "deploy:assets:precompile", "yarn:dependencies"
