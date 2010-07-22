class CrpIndustry < ActiveRecord::Base
  has_many :crp_interest_groups, :order => '"order"'
  belongs_to :crp_sector
  
  def top_recipients(chamber = 'house', num = 10)
    title = (chamber == 'house') ? 'Rep.' : 'Sen.'
    Person.find_by_sql("SELECT * FROM people INNER JOIN 
    (SELECT crp_contrib_individual_to_candidate.recipient_osid, SUM(crp_contrib_individual_to_candidate.amount) as contrib_total 
    FROM crp_contrib_individual_to_candidate
    INNER JOIN crp_interest_groups ON crp_interest_groups.osid=crp_contrib_individual_to_candidate.crp_interest_group_osid
    WHERE crp_interest_groups.crp_industry_id=#{id} AND crp_contrib_individual_to_candidate.cycle=#{CURRENT_OPENSECRETS_CYCLE} AND  
          crp_contrib_individual_to_candidate.contrib_type IN ('10', '11', '15 ', '15', '15E', '15J', '22Y') 
    GROUP BY crp_contrib_individual_to_candidate.recipient_osid)
     top_recips ON people.osid=top_recips.recipient_osid
     WHERE people.title='#{title}'
     ORDER BY top_recips.contrib_total DESC LIMIT #{num}")
  end
end