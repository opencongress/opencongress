class CrpInterestGroup < ActiveRecord::Base
  belongs_to :crp_industry
  
  def top_recipients(chamber = 'house', num = 10)
    title = (chamber == 'house') ? 'Rep.' : 'Sen.'
    Person.find_by_sql("SELECT * FROM people INNER JOIN 
    (SELECT recipient_osid, SUM(crp_contrib_individual_to_candidate.amount) as contrib_total 
    FROM crp_contrib_individual_to_candidate
    WHERE crp_interest_group_osid='#{osid}' AND cycle='2008' AND 
          contrib_type IN ('11', '15 ', '15J', '22Y')
     GROUP BY recipient_osid)
     top_recips ON people.osid=top_recips.recipient_osid
     WHERE people.title='#{title}'
     ORDER BY top_recips.contrib_total DESC LIMIT #{num}")
  end
end
