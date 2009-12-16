namespace :solr do

  desc "Rebuild the solr index"
  task :rebuild => :environment do
    require File.dirname(__FILE__) + '/../../app/controllers/application_controller'

    User.rebuild_solr_index(300)
    # Add other models here...
  end
end