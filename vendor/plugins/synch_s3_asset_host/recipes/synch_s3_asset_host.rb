require 'aws/s3'
require 'yaml'

# == Synopsis
#
# So you've got asset hosts (multiple or single) 
# running in your Rails application, and you're using Amazon's S3 to host your assets.  Now you want to make sure 
# that your assets are kept up to date.  This plugin is a Capistrano recipe that keeps the asset hosts synchronized 
# with the public directory in your subversion repository.
#
# == Usage
#
# After you get everything setup and do your first deploy, just run <tt>cap deploy</tt> as normal and all changed files 
# in <tt>RAILS_ROOT/public</tt> will be uploaded to all of your asset host buckets before the final <tt>deploy:symlink</tt> task.
#
# The following tasks are also available:
#
# * cap s3_asset_host:synch_public (This is the default task)
# * cap s3_asset_host:reset_and_synch
# * cap s3_asset_host:setup
# * cap s3_asset_host:create_buckets
# * cap s3_asset_host:delete_all
# * cap s3_asset_host:connect
#
# You can get documentation on these tasks by running 
#   cap -T
#
# == Requirements
#
# This plug-in is a Capistrano extension.  It requires Capistrano 2.0.0 or greater.
#
# You will also require the aws-s3 gem (http://amazon.rubyforge.org)
#
# This plugin should now work for any version control system or deployment method.
#
# If you want to use more than one asset host, then you have to either install the multiple asset hosts plugin 
# or upgrade to Rails 2.0 
# (see http://spattendesign.com/2007/10/24/setting-up-multiple-asset-hosts-in-rails)
#
# == Setup
#
# To set-up, you need to do the following
#
# * Install the AWS-S3 gem.
# * Set up your Rails application to use asset hosts.
# * Set up your asset hosts.
# * Configure Capistrano.
#
# === Installing the AWS-S3 gem
#
# You need to do this on both your local computer *and* the computer that is defined as the asset_host_syncher 
# (see Capistrano Configuration, below).
#
#   $> sudo gem install aws-s3@
#
# === Setting up your Rails app to use asset hosts
#
# ==== Single asset host
#
# For a single asset host, simply add the following line to <tt>RAILS_ROOT/config/environments/production.rb</tt>:
#
#   config.action_controller.asset_host = "http://assets.example.com"
#
# ==== Multiple asset hosts
#
# Follow the instructions in http://spattendesign.com/2007/10/24/setting-up-multiple-asset-hosts-in-rails
#
# === Setting up your asset hosts
#
# Set up a CNAME entry for each asset host pointing to s3.amazonaws.com.  How you do this depends on your domain host.  
# For an example of what it looks like on EasyDNS, see the original blog announcement for this plugin: http://spattendesign.com/2007/11/6/synching-your-amazon-s3-asset-host-using-capistrano
#
# You may need to wait up to 24 hours for the DNS entries for these new hosts to propagate.
#
# === Configuring Capistrano
#
# ==== Capistrano installation
#
# This plugin requires Capistrano 2.0.0 or greater.
#
# To upgrade to the latest version (currently 2.1.0):
#
#   $> gem install capistrano
#
# Once the plug-in is installed, make sure that the recipes are seen by Capistrano
#
#   $> cap -T | grep s3_asset_host@ 
#
# should return a bunch of tasks.  If you don't see anything listed, then you need to update your Capfile
# by doing the following (this is  from Jamis Buck at 
# http://groups.google.com/group/capistrano/browse_thread/thread/531ad32aff5fe5a8):
#
# In Capistrano 2.1.0 or above:
#
#   $> cd RAILS_ROOT
#   $> rm Capify
#   $> capify .
#
# If you do not want to delete your Capify file, or if you are using Capistrano 2.0.0, add the following 
# line to your Capify file:
#   Dir['vendor/plugins/*/recipes/*.rb'].each { |plugin| load(plugin) }
#
# ==== Capistrano configuration
#
# In <tt>RAILS_ROOT/config/deploy.rb</tt>
# Specify one of your web hosts as an "asset_host_syncher".  If you only have one web host, you don't make a new line for this, 
# just edit the existing line that sets your :web role
#
#   role :web, webserver1, :asset_host_syncher => true 
#
# tell Capistrano to synch your s3 hosts before doing the final symlink task:
#
#   before "deploy:symlink", "s3_asset_host:synch_public"
#
# ==== S3 configuration
#
# Create a file in <tt>RAILS_ROOT/config</tt> called <tt>synch_s3_asset_host.yml</tt>.  Add the following to it,
# and edit to suit:
#
#    AWS_ACCESS_KEY_ID: 'your access key here'
#    AWS_SECRET_ACCESS_KEY: 'your secret key here'
#    asset_host_name: "assets%d.example.com"     
#    # dry_run: false # Set to true if you want to test the asset_host uploading without doing anything on Amazon S3
#
# === The first deploy
#
# Commit all changes to your rails application, do the initial bucket setup and deploy:
#
#   $> svn commit -m "Adding synch_s3_asset_host plugin"
#   $> cap s3_asset_host:setup
#   $> cap deploy
#
# This will do the following:
# * Create your Amazon S3 AWS buckets
# * upload everything in <tt>RAILS_ROOT/public</tt> (in your svn repository) to each bucket
#
# This could take a while if you have lots of images or other big files.
#
# == You're done!
#
# That should do it.  Now, every time you run cap deploy, your asset hosts should be updated with any changes 
# to files in <tt>RAILS_ROOT/public</tt>.
#
# Let me know if you have any problems, suggestions or comments.
#
# == Contact Info
#
# This plug-in was written by Scott Patten of spatten design.  The original post announcing the plug-in was at
# http://spattendesign.com/2007/11/6/synching-your-amazon-s3-asset-host-using-capistrano
#
# Website:: http://spattendesign.com
# Blog:: http://spattendesign.com/blog
# email:: mailto:scott@spattendesign.com

RAILS_ROOT = File.join(File.dirname(__FILE__), "../../../..")
NUM_ASSET_HOSTS = 4
CONFIG_FILENAME = File.join(File.dirname(__FILE__), "../../../..", 'config', 'synch_s3_asset_host.yml')

def asset_hosts
  (0 ... NUM_ASSET_HOSTS).collect {|n| fetch(:asset_host_name) % n }.uniq
end 

namespace :s3_asset_host do
  
  task :default do
    synch_public
  end
  
  desc "Loads the S3 id and secret from the .yaml file set in CONFIG_FILENAME"
  task :load_config do
    s3sync_config = YAML::load(File.open(CONFIG_FILENAME))
    s3sync_config.each do |key, value|
      set(key.downcase.to_sym, value)
    end
  end

  desc "Synchronizes the public directory with your asset hosts."
  task :synch_public, :roles => :web, :only => {:asset_host_syncher => true} do
    connect
    current_release_dir = fetch(:latest_release)
    asset_hosts.each do |host|
      command = "cd #{File.join(current_release_dir, 'vendor/plugins/synch_s3_asset_host/s3sync')} && "
      command += "./s3sync.rb --recursive --config-file #{File.join(current_release_dir, "config/synch_s3_asset_host.yml")} "
      # command += "--exclude \"\\.svn|\\.DS_Store\" --public-read "
      command += "--exclude \"\\.svn|\\.DS_Store|system\" --public-read "      
      command += "--dryrun " if fetch(:dry_run, false)
      command += "#{File.join(current_release_dir, 'public')}/ #{host}:" 
      run(command)
    end   
  end
  
  desc "Deletes and re-creates all of your asset host buckets and then uploads everything to them"
  task :reset_and_synch do
    connect
    delete_all
    synch_public  
  end
  
  desc "An alias for create_buckets"
  task :setup do
    create_buckets
  end
  
  desc "Creates all of your asset host buckets"
  task :create_buckets do   
    connect 
    asset_hosts.each do |host|
      puts "#{'DRY RUN: ' if fetch(:dry_run, false)}creating bucket #{host}"            
      AWS::S3::Bucket.create(host, :force => true) unless fetch(:dry_run, false)
    end
  end
  
  desc "Deletes and then re-creates all of your asset host buckets"
  task :delete_all do
    connect
    asset_hosts.each do |host|
      puts "#{'DRY RUN: ' if fetch(:dry_run, false)}Deleting bucket #{host} and all of its contents"      
      AWS::S3::Bucket.delete(host, :force => true) unless fetch(:dry_run, false)
    end
    create_buckets
  end
  
  desc "Connects to your Amazon S3 instance.  See the documentation for how to provide your " +
       "credentials for Amazon S3."
  task :connect do
    load_config
    unless AWS::S3::Base.connected?
      AWS::S3::Base.establish_connection!(
          :access_key_id     => fetch(:aws_access_key_id, nil),
          :secret_access_key => fetch(:aws_secret_access_key, nil)
        )
    end  
    raise "\nERROR: Connection to Amazon S3 not made or bad access key or bad secret access key.  Exiting" unless AWS::S3::Base.connected?     
  end
  
end