# PrunOps

Covers all Deployment and maintainance Operations in a Ruby on Rails Application server:

1. DEPLOYMENT: Capistrano tasks to depoly your rails Apps.
1. DIAGNOSIS: Capistrano diagnosis tools to guet your Apps status on real time.
1. RELEASE: Rake tasks to manage and tag version number in your Apps (X.Y.Z).
1. BACKUP: Backup policy for database and files in your Apps, using git as storage.

Based on:

* [PRUN Docker image](https://registry.hub.docker.com/u/jlebrijo/prun/).
* [PRUN Chef recipe](https://github.com/jlebrijo/prun-cfg).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'prun-ops'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install prun-ops

## Usage: Day-to-day rake and capistrano tasks

### Configure Capistrano

`gem "capistrano-rails"` is included as prun-ops requirement. Create basic files `cap install`

Capfile should include these requirements:

```ruby
require 'capistrano/setup'
require 'capistrano/deploy'
require 'capistrano/rails'
require 'capistrano/bundler'
require 'capistrano/rails/assets'
require 'capistrano/rails/migrations'
require "#{File.dirname(__FILE__)}/config/application"
require 'capistrano/prun-ops'
Dir.glob('lib/capistrano/tasks/*.rake').each { |r| import r }
```

Notice that you are adding all prun-ops tasks with the line `require 'capistrano/prun-ops'`

Your config/deploy/production.rb:

```
server "example.com", user: 'root', roles: %w{web app db}, port: 2222
```

Note: Remember change this line in production.rb file: `config.assets.compile = true`

### Deployment

* `cap [stg] deploy` deploy your app as usual
* `cap [stg] deploy:restart` restart thin server of this application
* `cap [stg] deploy:stop` stop thin server
* `cap [stg] deploy:start` start thin server
* `cap [stg] db:setup` load schema and seeds for first DB setup
* `cap [stg] git:remove_repo` Removes repo (useful when repo_url changes)

Added the possibility of deploying from local repository. Add to `deploy.rb` or `[stg].rb` files:

```
before :deploy, "git:deploy_from_local_repo"
```

Take care to remove the previous repo if you are changing the :repo_url : `cap [stg] git:remove_repo`


### Backup

Backups/restore database and files in your Rails app.

Configure your 'config/applciation.rb':

```ruby
  # Backup directories
  config.backup_dirs = %w{public/ckeditor_assets public/system}

  # Backup repo
  config.backup_repo = "git@github.com:example/backup.git"
```

And
![backup schema](https://docs.google.com/drawings/d/1Sp8ysn46ldIWRxaLUHfzpu7vK0zMjh4_iMpEP1U6SuU/pub?w=642&h=277  "Backup commands schema")

* `cap [stg] pull:data`: downloads DDBB and file folders from the stage you need.
* `cap [stg] backup[TAG]`: Commit a backup of DDBB and files to the git repo configured. "application-YYYYMMDD" tagged if no tag is provided.
* `cap [stg] backup:restore[TAG]`: Restore the last backup into the stage indicated, or tagged state if TAG is provided.
* `rake backup |TAG|`: Uploads backup to git store from local, tagging with date, or with TAG if provided. Useful to backup production stage.
* `rake backup:restore |TAG|`: Restore last backup copy, or tagged with TAG if provided.

### TODO: Release

Release management

* `rake release |VERSION|` push forward from dev-branch to master-branch and tag the commit with VERSION name.
* `rake release:delete |VERSION|` remove tag with VERSION name.
* `rake git:ff` merge dev branch towards master branch without releasing (Deprecating, new version "rake tomaster[message]")

![Release management](https://docs.google.com/drawings/d/1PLIQ8SMagUo1438RNShl99Ux3daFutmRgIsbQqhJ2n4/pub?w=917&h=551  "Release management")


### Diagnosis

Some capistrano commands useful to connect to server and help with the problem solving.

* `cap [stg] ssh` open a ssh connection with server
* `cap [stg] log[LOG_FILENAME]` tail rails log by default, or other if LOG_FILENAME is provided
* `cap [stg] c` open a rails console with server
* `cap [stg] x[COMMAND]` execute any command in server provided as COMMAND (i.e.: cap production x['free -m'])

### Monitoring

Recommend to configure your Rails server with [PRUN Chef recipe](https://github.com/jlebrijo/prun-cfg).

At this moment we are implementing [NewRelic](http://newrelic.com/) monitoring, including as dependency ['newrelic_rpm'](https://github.com/newrelic/rpm) gem. To configure yourproject you just need to create an account at [NewRelic](http://newrelic.com/)  and follow the instructions (creating a 'config/newrelic.yml file with your license_key).

## Contributing

1. Fork it ( https://github.com/[my-github-username]/prun-ops/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

[MIT License](http://opensource.org/licenses/MIT). Made by [Lebrijo.com](http://lebrijo.com)

## Release notes

### v0.0.2

* First publication

### v0.0.4

* Changing homepage and License
* start|stop|restart thin server per application as Capistrano task

### v0.0.5

* Removing Application server version (thin 1.6.2) dependency

### v0.0.6

* Fixing DigitalOcean images error when slug is nil for client images
* Adding git:ff rake task

### v0.0.8

* Adding backup[tag] capistrano task for production

### v0.0.9

* Fixing Capistrano pulling tasks "pull:data"

### v0.0.10

* Removing bin/ops command in order to create open-dock gem
* Remove prun-ops dependency from 'config/deployment.rb' file and ad it to 'Capfile' as `require 'capistrano/prun-ops'`

### v0.0.21

* Remove from your 'config/deploy.rb':

```ruby
    # Backup directories
    require_relative "./application.rb"
    set :backup_dirs, Taskboard::Application.config.backup_dirs
```

Also add in your Capfile:

```ruby
................
require 'capistrano/rails/migrations'
require "#{File.dirname(__FILE__)}/config/application"
require 'capistrano/prun-ops'
................
```