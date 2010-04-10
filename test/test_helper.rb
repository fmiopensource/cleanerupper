require 'rubygems'
require 'active_support'
require 'active_support/test_case'

if ENV['RAILS'].nil?
  require File.expand_path(File.join(File.dirname(__FILE__), '../../../../config/environment.rb'))
else
  # specific rails version targeted
  # load activerecord and plugin manually
  gem 'activerecord', "=#{ENV['RAILS']}"
  require 'active_record'
  $LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
  Dir["#{$LOAD_PATH.last}/**/*.rb"].each do |path|
    require path[$LOAD_PATH.last.size + 1..-1]
  end
  require File.join(File.dirname(__FILE__), '..', 'init.rb')
end

config = YAML::load(IO.read(File.dirname(__FILE__) + '/database.yml'))
# do this so fixtures will load
ActiveRecord::Base.configurations.update config
ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/debug.log")
ActiveRecord::Base.establish_connection(config[ENV['DB'] || 'sqlite3'])

load(File.dirname(__FILE__) + "/schema.rb")

require File.expand_path(File.dirname(__FILE__) + "/../lib/cleanerupper.rb")
ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../../../../config/environment")
require 'test_help'