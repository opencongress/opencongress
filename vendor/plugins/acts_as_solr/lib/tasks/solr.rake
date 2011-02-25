require 'rubygems'
require 'rake'
require 'net/http'
require 'active_record'

namespace :solr do

  desc 'Starts Solr. Options accepted: RAILS_ENV=your_env, PORT=XX. Defaults to development if none.'
  task :start do
    require "#{File.dirname(__FILE__)}/../../config/solr_environment.rb"
    begin
      n = Net::HTTP.new('127.0.0.1', SOLR_PORT)
      n.request_head('/').value 

    rescue Net::HTTPServerException #responding
      puts "Port #{SOLR_PORT} in use" and return

    rescue Errno::ECONNREFUSED #not responding
      Dir.chdir(SOLR_PATH) do
        pid = fork do
          #STDERR.close
          exec "java #{SOLR_JVM_OPTIONS} -Dsolr.data.dir=#{SOLR_DATA_PATH} -Djetty.logs=#{SOLR_LOGS_PATH} -Djetty.port=#{SOLR_PORT} -jar start.jar"
        end
        sleep(5)
        File.open("#{SOLR_PIDS_PATH}/#{ENV['RAILS_ENV']}_pid", "w"){ |f| f << pid}
        puts "#{ENV['RAILS_ENV']} Solr started successfully on #{SOLR_PORT}, pid: #{pid}."
      end
    end
  end
  
  desc 'Stops Solr. Specify the environment by using: RAILS_ENV=your_env. Defaults to development if none.'
  task :stop do
    require "#{File.dirname(__FILE__)}/../../config/solr_environment.rb"
    fork do
      file_path = "#{SOLR_PIDS_PATH}/#{ENV['RAILS_ENV']}_pid"
      if File.exists?(file_path)
        File.open(file_path, "r") do |f| 
          pid = f.readline
          Process.kill('TERM', pid.to_i)
        end
        File.unlink(file_path)
        Rake::Task["solr:destroy_index"].invoke if ENV['RAILS_ENV'] == 'test'
        puts "Solr shutdown successfully."
      else
        puts "PID file not found at #{file_path}. Either Solr is not running or no PID file was written."
      end
    end
  end
  
  desc 'Remove Solr index'
  task :destroy_index do
    require "#{File.dirname(__FILE__)}/../../config/solr_environment.rb"
    raise "In production mode.  I'm not going to delete the index, sorry." if ENV['RAILS_ENV'] == "production"
    if File.exists?("#{SOLR_DATA_PATH}")
      Dir["#{SOLR_DATA_PATH}/index/*"].each{|f| File.unlink(f)}
      Dir.rmdir("#{SOLR_DATA_PATH}/index")
      puts "Index files removed under " + ENV['RAILS_ENV'] + " environment"
    end
  end
  
  # this task is by Henrik Nyh
  # http://henrik.nyh.se/2007/06/rake-task-to-reindex-models-for-acts_as_solr
  desc %{Reindexes data for all acts_as_solr models. Clears index first to get rid of orphaned records and optimizes index afterwards. RAILS_ENV=your_env to set environment. ONLY=book,person,magazine to only reindex those models; EXCEPT=book,magazine to exclude those models. START_SERVER=true to solr:start before and solr:stop after. BATCH=123 to post/commit in batches of that size: default is 300. CLEAR=false to not clear the index first; OPTIMIZE=false to not optimize the index afterwards.}
  task :reindex => :environment do
    require "#{File.dirname(__FILE__)}/../../config/solr_environment.rb"

    includes = env_array_to_constants('ONLY')
    if includes.empty?
      includes = Dir.glob("#{RAILS_ROOT}/app/models/*.rb").map { |path| File.basename(path, ".rb").camelize.constantize }
    end
    excludes = env_array_to_constants('EXCEPT')
    includes -= excludes
    
    optimize            = env_to_bool('OPTIMIZE',     true)
    start_server        = env_to_bool('START_SERVER', false)
    clear_first         = env_to_bool('CLEAR',       true)
    batch_size          = ENV['BATCH'].to_i.nonzero? || 300
    debug_output        = env_to_bool("DEBUG", false)

    RAILS_DEFAULT_LOGGER.level = ActiveSupport::BufferedLogger::INFO unless debug_output

    if start_server
      puts "Starting Solr server..."
      Rake::Task["solr:start"].invoke 
    end
    
    # Disable solr_optimize
    module ActsAsSolr::CommonMethods
      def blank() end
      alias_method :deferred_solr_optimize, :solr_optimize
      alias_method :solr_optimize, :blank
    end
    
    models = includes.select { |m| m.respond_to?(:rebuild_solr_index) }    
    models.each do |model|
  
      if clear_first
        puts "Clearing index for #{model}..."
        ActsAsSolr::Post.execute(Solr::Request::Delete.new(:query => "#{model.solr_configuration[:type_field]}:#{model}")) 
        ActsAsSolr::Post.execute(Solr::Request::Commit.new)
      end
      
      puts "Rebuilding index for #{model}..."
      model.rebuild_solr_index(batch_size)

    end 

    if models.empty?
      puts "There were no models to reindex."
    elsif optimize
      puts "Optimizing..."
      models.last.deferred_solr_optimize
    end

    if start_server
      puts "Shutting down Solr server..."
      Rake::Task["solr:stop"].invoke 
    end
    
  end
  
  def env_array_to_constants(env)
    env = ENV[env] || ''
    env.split(/\s*,\s*/).map { |m| m.singularize.camelize.constantize }.uniq
  end
  
  def env_to_bool(env, default)
    env = ENV[env] || ''
    case env
      when /^true$/i then true
      when /^false$/i then false
      else default
    end
  end

end

