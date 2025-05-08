## [Unreleased]

## v0.0.2

- First publication

## v0.0.4

- Changing homepage and License
- start|stop|restart thin server per application as Capistrano task

## v0.0.5

- Removing Application server version (thin 1.6.2) dependency

## v0.0.6

- Fixing DigitalOcean images error when slug is nil for client images
- Adding git:ff rake task

## v0.0.8

- Adding backup[tag] capistrano task for production

## v0.0.9

- Fixing Capistrano pulling tasks "pull:data"

## v0.0.10

- Removing bin/ops command in order to create open-dock gem
- Remove prun-ops dependency from 'config/deployment.rb' file and ad it to 'Capfile' as `require 'capistrano/prun-ops'`

## v0.0.21

- Remove from your 'config/deploy.rb':

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

## v0.1.2

- Add `cap stage dbconsole` to open a database console.

## v0.1.6

- Add `cap stage rake[db:create]` to execute a rake task in remote server.

## v0.2.0

- Configuration tasks: Add `cap stage config` and other tasks.

## v0.2.8

- Bastion command

## v0.3.3

- Including Cred to easy manage encrypted credentials

## [0.4.0] - 2025-05-08

- Upgrade to Ruby 3.4.3
