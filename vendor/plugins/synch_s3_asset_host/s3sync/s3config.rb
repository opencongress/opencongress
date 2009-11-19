#!/usr/bin/ruby
# This software code is made available "AS IS" without warranties of any        
# kind.  You may copy, display, modify and redistribute the software            
# code either by itself or as incorporated into your code; provided that        
# you do not remove any proprietary notices.  Your use of this software         
# code is at your own risk and you waive any claim against the author
# with respect to your use of this software code. 
# (c) 2007 alastair brunton
#
 
require 'yaml'
 
 
module S3Config
  
  DEFAULT_CONFIG_FILE = 's3config.yml'
  
  def S3Config.load_config(config_file = DEFAULT_CONFIG_FILE)
    if File.exists?(config_file)
      config = YAML.load_file( config_file )
      config.each_pair do |key, value|
         eval("$#{key.upcase} = '#{value}'")
      end
    end
  end
 
end
