require 'prun/ops'
require 'rails'
module PrunOps
  class Railtie < Rails::Railtie
    rake_tasks do
      Dir.glob("#{File.dirname(__FILE__)}/../tasks/*.rake").each { |r| load r }
    end
  end
end