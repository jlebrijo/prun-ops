namespace :db do
  desc "Reset DataBase for environment and test"
  task :reset do
    Rake::Task['db:drop'].invoke
    Rake::Task['db:create'].invoke
    Rake::Task['db:migrate'].invoke
    Rake::Task['db:seed'].invoke
    sh "rake db:test:prepare"
  end

  desc "Backup the database tp tmp/db.sql file"
  task backup: :get_db_config do
    if @url
      sh "pg_dump -d #{@url} -f #{filename}"
    else
      sh "export PGPASSWORD=#{@password} && pg_dump #{@database} --host #{@host} --port #{@port} -U #{@username} -f #{@default_filename}"
    end

  end

  desc "Restore the database from tmp/db.sql file if no one is passed"
  task restore: [:drop, :create, :get_db_config] do
    sh "export PGPASSWORD=#{@password} && psql -d #{@database} -U #{@username} -h #{@host} --port #{@port} < #{filename}"
  end
end

task :get_db_config do
  config   = Rails.configuration.database_configuration
  @host = config[Rails.env]["host"]
  @port = config[Rails.env]["port"]
  @database = config[Rails.env]["database"]
  @username = config[Rails.env]["username"]
  @password = config[Rails.env]["password"]
  @url = config[Rails.env]["url"]

  @default_filename = "tmp/db.sql"
end

def filename
  name = ARGV[1]
  task name.to_sym do ; end unless name.nil?
  return name ? name : @default_filename
end



