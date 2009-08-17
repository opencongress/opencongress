namespace :cache do
  desc "scripts for dealing with the cache"
  
  task :expire_index => :environment do
    require File.dirname(__FILE__) + '/../../app/controllers/application'
    IndexController.expire_page("/index")
    
    # reload the page
    system "wget http://www.opencongress.org -O /dev/null"
  end

  task :expire_footer => :environment do
    require 'action_controller/integration'
    
    FragmentCacheSweeper::expire_fragments(["layout_footer"])
  end
end