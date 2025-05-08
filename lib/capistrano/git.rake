# frozen_string_literal: true

namespace :git do
  desc "Git pull for common code project"
  task :pull_common do
    on roles(:app) do
      if test("[ -d /var/www/common ]")
        within "/var/www/common" do
          execute :git, :pull, :origin, :master
        end
      end
    end
  end
  after "deploy:updating", "git:pull_common"

  desc "Deploy from local git repository"
  task :deploy_from_local_repo do
    set :repo_url, "file:///tmp/.git"
    run_locally do
      execute "tar -zcvf /tmp/repo.tgz .git"
    end
    on roles(:all) do
      upload! "/tmp/repo.tgz", "/tmp/repo.tgz"
      execute "tar -zxvf /tmp/repo.tgz -C /tmp"
    end
  end

  desc "Removes repo (useful when repo_url changes)"
  task :remove_repo do
    on roles(:all) do
      execute "rm -r #{repo_path}"
    end
  end
end
