class CreateListRepresentatives < ActiveRecord::Migration
  def self.up
    if Rails.env.production?
     execute 'create or replace view list_representatives as SELECT people.*, 
   	       COALESCE(person_approvals.person_approval_avg, 0) as person_approval_average,
   	       COALESCE(bills_sponsored.sponsored_bills_count, 0) as sponsored_bills_count,
   	       COALESCE(total_rolls.tcalls, 0) as total_roll_call_votes,
   	       CASE WHEN people.party = \'Democrat\' THEN COALESCE(party_votes_democrat.pcount, 0)
   	            WHEN people.party = \'Republican\' THEN COALESCE(party_votes_republican.pcount, 0)
   	            ELSE 0
   	       END as party_roll_call_votes,
   	       COALESCE(most_viewed.view_count, 0) as view_count,
   	       COALESCE(blogs.blog_count, 0) as blog_count,
   	       COALESCE(news.news_count, 0) as news_count
   	    FROM people
   	    LEFT OUTER JOIN (select person_approvals.person_id as person_approval_id, 
   	                     count(person_approvals.id) as person_approval_count, 
   	                     avg(person_approvals.rating) as person_approval_avg 
   	                    FROM person_approvals
   	                    GROUP BY person_approval_id) person_approvals
   		  ON person_approval_id = people.id
   	    LEFT OUTER JOIN (select sponsor_id, count(id) as sponsored_bills_count
   	                    FROM bills
   	                    WHERE bills.session = 111
   	                    GROUP BY sponsor_id) bills_sponsored
   	      ON bills_sponsored.sponsor_id = people.id
   	    LEFT OUTER JOIN (SELECT DISTINCT(roll_call_votes.person_id), count(DISTINCT "roll_calls".id) AS tcalls 
   	                    FROM "roll_calls" 
   	                    LEFT OUTER JOIN "bills" ON "bills".id = "roll_calls".bill_id 
   	                    INNER JOIN "roll_call_votes" ON "roll_calls".id = "roll_call_votes".roll_call_id 
   	                      WHERE roll_call_votes.vote != \'0\' AND bills.session = 111
   	                      GROUP BY roll_call_votes.person_id) total_rolls
   				          ON total_rolls.person_id = people.id
   	    LEFT OUTER JOIN (SELECT DISTINCT(roll_call_votes.person_id), count(DISTINCT "roll_calls".id) AS pcount 
   	                     FROM "roll_calls" 
   	                     LEFT OUTER JOIN "bills" ON "bills".id = "roll_calls".bill_id 
   	                     INNER JOIN "roll_call_votes" ON "roll_calls".id = "roll_call_votes".roll_call_id 
   	                     WHERE ((roll_calls.democratic_position = true AND vote = \'+\') OR (roll_calls.democratic_position = false AND vote = \'-\')) 
   	                     AND bills.session = 111
   		             GROUP BY roll_call_votes.person_id) party_votes_democrat
   			     ON party_votes_democrat.person_id = people.id
        	    LEFT OUTER JOIN (SELECT DISTINCT(roll_call_votes.person_id), count(DISTINCT "roll_calls".id) AS pcount 
        	                     FROM "roll_calls" 
        	                     LEFT OUTER JOIN "bills" ON "bills".id = "roll_calls".bill_id 
        	                     INNER JOIN "roll_call_votes" ON "roll_calls".id = "roll_call_votes".roll_call_id 
        	                     WHERE ((roll_calls.republican_position = true AND vote = \'+\') OR (roll_calls.republican_position = false AND vote = \'-\')) 
        	                     AND bills.session = 111
        		             GROUP BY roll_call_votes.person_id) party_votes_republican
        			     ON party_votes_republican.person_id = people.id
               LEFT OUTER JOIN (SELECT page_views.viewable_id,
                                              count(page_views.viewable_id) AS view_count
                                       FROM page_views 
                                       WHERE page_views.created_at > current_timestamp - interval \'7 days\' AND
                                             page_views.viewable_type = \'Person\'
                                       GROUP BY page_views.viewable_id
                                       ORDER BY view_count DESC) most_viewed
                                      ON people.id=most_viewed.viewable_id
               LEFT OUTER JOIN (SELECT count(commentaries.id) as blog_count, commentaries.commentariable_id
                                       FROM commentaries 
                                       WHERE commentaries.date > current_timestamp - interval \'7 days\' AND
                                             commentaries.is_news = \'f\' AND 
                                             commentaries.commentariable_type = \'Person\'
                                       GROUP BY commentaries.commentariable_id
                                       ORDER BY blog_count DESC) blogs
                                      ON people.id=blogs.commentariable_id      
               LEFT OUTER JOIN (SELECT count(commentaries.id) as news_count, commentaries.commentariable_id
                                       FROM commentaries 
                                       WHERE commentaries.date > current_timestamp - interval \'7 days\' AND
                                             commentaries.commentariable_type = \'Person\' AND commentaries.is_news = \'t\'
                                       GROUP BY commentaries.commentariable_id
                                       ORDER BY news_count DESC) news
                                      ON people.id=news.commentariable_id                                                                  			       
   	    WHERE people.title = \'Rep.\';'
   	  else
        execute 'create or replace view list_representatives as SELECT people.*, 
      	       COALESCE(person_approvals.person_approval_avg, 0) as person_approval_average,
      	       COALESCE(bills_sponsored.sponsored_bills_count, 0) as sponsored_bills_count,
      	       COALESCE(total_rolls.tcalls, 0) as total_roll_call_votes,
      	       CASE WHEN people.party = \'Democrat\' THEN COALESCE(party_votes_democrat.pcount, 0)
      	            WHEN people.party = \'Republican\' THEN COALESCE(party_votes_republican.pcount, 0)
      	            ELSE 0
      	       END as party_roll_call_votes,
      	       COALESCE(most_viewed.view_count, 0) as view_count,
      	       COALESCE(blogs.blog_count, 0) as blog_count,
      	       COALESCE(news.news_count, 0) as news_count
      	    FROM people
      	    LEFT OUTER JOIN (select person_approvals.person_id as person_approval_id, 
      	                     count(person_approvals.id) as person_approval_count, 
      	                     avg(person_approvals.rating) as person_approval_avg 
      	                    FROM person_approvals
      	                    GROUP BY person_approval_id) person_approvals
      		  ON person_approval_id = people.id
      	    LEFT OUTER JOIN (select sponsor_id, count(id) as sponsored_bills_count
      	                    FROM bills
      	                    WHERE bills.session = 111
      	                    GROUP BY sponsor_id) bills_sponsored
      	      ON bills_sponsored.sponsor_id = people.id
      	    LEFT OUTER JOIN (SELECT DISTINCT(roll_call_votes.person_id), count(DISTINCT "roll_calls".id) AS tcalls 
      	                    FROM "roll_calls" 
      	                    LEFT OUTER JOIN "bills" ON "bills".id = "roll_calls".bill_id 
      	                    INNER JOIN "roll_call_votes" ON "roll_calls".id = "roll_call_votes".roll_call_id 
      	                      WHERE roll_call_votes.vote != \'0\' AND bills.session = 111
      	                      GROUP BY roll_call_votes.person_id) total_rolls
      				          ON total_rolls.person_id = people.id
      	    LEFT OUTER JOIN (SELECT DISTINCT(roll_call_votes.person_id), count(DISTINCT "roll_calls".id) AS pcount 
      	                     FROM "roll_calls" 
      	                     LEFT OUTER JOIN "bills" ON "bills".id = "roll_calls".bill_id 
      	                     INNER JOIN "roll_call_votes" ON "roll_calls".id = "roll_call_votes".roll_call_id 
      	                     WHERE ((roll_calls.democratic_position = true AND vote = \'+\') OR (roll_calls.democratic_position = false AND vote = \'-\')) 
      	                     AND bills.session = 111
      		             GROUP BY roll_call_votes.person_id) party_votes_democrat
      			     ON party_votes_democrat.person_id = people.id
           	    LEFT OUTER JOIN (SELECT DISTINCT(roll_call_votes.person_id), count(DISTINCT "roll_calls".id) AS pcount 
           	                     FROM "roll_calls" 
           	                     LEFT OUTER JOIN "bills" ON "bills".id = "roll_calls".bill_id 
           	                     INNER JOIN "roll_call_votes" ON "roll_calls".id = "roll_call_votes".roll_call_id 
           	                     WHERE ((roll_calls.republican_position = true AND vote = \'+\') OR (roll_calls.republican_position = false AND vote = \'-\')) 
           	                     AND bills.session = 111
           		             GROUP BY roll_call_votes.person_id) party_votes_republican
           			     ON party_votes_republican.person_id = people.id
                  LEFT OUTER JOIN (SELECT page_views.viewable_id,
                                                 count(page_views.viewable_id) AS view_count
                                          FROM page_views 
                                          WHERE page_views.created_at > current_timestamp - interval \'128 days\' AND
                                                page_views.viewable_type = \'Person\'
                                          GROUP BY page_views.viewable_id
                                          ORDER BY view_count DESC) most_viewed
                                         ON people.id=most_viewed.viewable_id
                  LEFT OUTER JOIN (SELECT count(commentaries.id) as blog_count, commentaries.commentariable_id
                                          FROM commentaries 
                                          WHERE commentaries.date > current_timestamp - interval \'128 days\' AND
                                                commentaries.is_news = \'f\' AND 
                                                commentaries.commentariable_type = \'Person\'
                                          GROUP BY commentaries.commentariable_id
                                          ORDER BY blog_count DESC) blogs
                                         ON people.id=blogs.commentariable_id      
                  LEFT OUTER JOIN (SELECT count(commentaries.id) as news_count, commentaries.commentariable_id
                                          FROM commentaries 
                                          WHERE commentaries.date > current_timestamp - interval \'128 days\' AND
                                                commentaries.commentariable_type = \'Person\' AND commentaries.is_news = \'t\'
                                          GROUP BY commentaries.commentariable_id
                                          ORDER BY news_count DESC) news
                                         ON people.id=news.commentariable_id                                                                  			       
      	    WHERE people.title = \'Rep.\';'
   	    
 	    end
  end

  def self.down
    execute "drop view list_representatives;"
  end
end
