task :config do
  invoke 'ubuntu:install'
  invoke 'ruby:install'
  invoke 'rails:prepare'
  invoke 'postgres:install'
  invoke 'nginx:install'
  invoke 'nodejs:install'
  invoke 'yarn:install'
  invoke 'app:prepare'
  invoke 'deploy:upload_linked_files'
  # invoke 'app:db_prepare'
end