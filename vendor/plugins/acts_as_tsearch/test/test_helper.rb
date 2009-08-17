require 'rubygems'
require 'test/unit'
require 'active_record'
require 'active_record/fixtures'
require "#{File.dirname(__FILE__)}/../init"

config = YAML::load(IO.read(File.dirname(__FILE__) + '/database.yml'))
ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/debug.log")
ActiveRecord::Base.establish_connection(config[ENV['DB'] || 'postgresql'])

load(File.dirname(__FILE__) + "/schema.rb") if File.exist?(File.dirname(__FILE__) + "/schema.rb")

FIXTURES_PATH = File.join(File.dirname(__FILE__), '/fixtures')
dep = defined?(ActiveSupport::Dependencies) ? ActiveSupport::Dependencies : ::Dependencies
dep.load_paths.unshift FIXTURES_PATH


class Test::Unit::TestCase #:nodoc:  
  def create_fixtures(*table_names)
    if block_given?
      Fixtures.create_fixtures(FIXTURES_PATH, table_names) { yield }
    else
      Fixtures.create_fixtures(FIXTURES_PATH, table_names)
    end
  end
end
