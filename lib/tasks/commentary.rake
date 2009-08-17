namespace :commentary do
  desc "tasks to search for news and blog posts on the web"
  
  task :all_bills_for_current_session => :environment do
    begin
      require 'commentary_parser'
      CommentaryParser.all_bills_for_current_session
    rescue Exception => e
      Emailer.deliver_rake_error(e, "Error with commentary parse all_bills_for_current_session!")
      throw e
    end
  end

  task :all_people_for_current_session => :environment do
    begin
      require 'commentary_parser'
      CommentaryParser.all_people_for_current_session
    rescue Exception => e
      Emailer.deliver_rake_error(e, "Error with commentary parse all_people_for_current_session!")
      throw e
    end
  end
  
  task :most_viewed_and_recent_activity_bills => :environment do
    begin
      require 'commentary_parser'
      CommentaryParser.most_viewed_and_recent_activity_bills
    rescue Exception => e
      Emailer.deliver_rake_error(e, "Error with commentary parse most_viewed_and_recent_activity_bills!")
      throw e
    end
  end

  task :recent_referrers => :environment do
    begin
      require 'commentary_parser'
      CommentaryParser.recent_referrers
    rescue Exception => e
      Emailer.deliver_rake_error(e, "Error with commentary parse recent_referrers!")
      throw e
    end
  end
end