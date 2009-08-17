namespace :data do
  desc "tools for migrating data between databases, etc"
  
  task :migrate_site_text => :environment do
    SiteText.transaction {
      load 'bin/migrate_site_text.rb'
    }
  end
  
  task :migrate_sidebars => :environment do
    Sidebar.transaction {
      load 'bin/migrate_sidebars.rb'
    }
  end
end