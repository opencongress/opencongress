ENV['RAILS_ENV']  = (ENV['RAILS_ENV'] || 'development').dup
# RAILS_ROOT isn't defined yet, so figure it out.

rails_root_dir = "#{File.expand_path('.')}"
SOLR_PATH = "#{File.dirname(File.expand_path(__FILE__))}/../solr" unless defined? SOLR_PATH

SOLR_LOGS_PATH = "#{rails_root_dir}/log" unless defined? SOLR_LOGS_PATH
SOLR_PIDS_PATH = "#{rails_root_dir}/tmp/pids" unless defined? SOLR_PIDS_PATH
SOLR_DATA_PATH = "#{rails_root_dir}/solr/#{ENV['RAILS_ENV']}" unless defined? SOLR_DATA_PATH

unless defined? SOLR_PORT
  config = YAML::load_file(rails_root_dir+'/config/solr.yml')
  
  begin
    SOLR_PORT = ENV['PORT'] || URI.parse(config[ENV['RAILS_ENV']]['url']).port
  rescue
    STDERR.puts "Couldn't set Solr port"
    SOLR_PORT = 8982
  end
end

begin
  SOLR_JVM_OPTIONS = config[ENV['RAILS_ENV']]['jvm_options'] unless defined? SOLR_JVM_OPTIONS
rescue 
  STDERR.puts "Couldn't set JVM Options"
  SOLR_JVM_OPTIONS = ""
end

if ENV['RAILS_ENV'] == 'test'
  DB = (ENV['DB'] ? ENV['DB'] : 'mysql') unless defined?(DB)
  MYSQL_USER = (ENV['MYSQL_USER'].nil? ? 'root' : ENV['MYSQL_USER']) unless defined? MYSQL_USER
  require File.join(File.dirname(File.expand_path(__FILE__)), '..', 'test', 'db', 'connections', DB, 'connection.rb')
end
