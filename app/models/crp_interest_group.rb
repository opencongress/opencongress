class CrpInterestGroup < ActiveRecord::Base
  belongs_to :crp_industry
  
  def top_recipients(chamber = 'house', num = 10, cycle = Settings.current_opensecrets_cycle)
    
    title = (chamber == 'house') ? 'Rep.' : 'Sen.'
    Person.find_by_sql(["SELECT people.*, top_recips_ind.ind_contrib_total, top_recips_pac.pac_contrib_total, (COALESCE(top_recips_ind.ind_contrib_total, 0) + COALESCE(top_recips_pac.pac_contrib_total, 0)) AS contrib_total FROM people
      LEFT JOIN 
        (SELECT recipient_osid, SUM(crp_contrib_individual_to_candidate.amount) as ind_contrib_total 
         FROM crp_contrib_individual_to_candidate
         WHERE crp_interest_group_osid=? AND cycle=? AND crp_contrib_individual_to_candidate.contrib_type IN ('10', '11', '15 ', '15', '15E', '15J', '22Y')
         GROUP BY recipient_osid) 
        top_recips_ind ON people.osid=top_recips_ind.recipient_osid
      LEFT JOIN
        (SELECT recipient_osid, SUM(crp_contrib_pac_to_candidate.amount) as pac_contrib_total 
         FROM crp_contrib_pac_to_candidate
         WHERE crp_contrib_pac_to_candidate.crp_interest_group_osid=? AND crp_contrib_pac_to_candidate.cycle=?
         GROUP BY crp_contrib_pac_to_candidate.recipient_osid) 
        top_recips_pac ON people.osid=top_recips_pac.recipient_osid
     WHERE people.title=?
     ORDER BY contrib_total DESC
     LIMIT ?", osid, Settings.current_opensecrets_cycle, osid, Settings.current_opensecrets_cycle, title, num])
  end
  
  def contrib_for_person(person)
    p = Person.find_by_sql(["SELECT people.*, top_recips_ind.ind_contrib_total, top_recips_pac.pac_contrib_total, (COALESCE(top_recips_ind.ind_contrib_total, 0) + COALESCE(top_recips_pac.pac_contrib_total, 0)) AS contrib_total FROM people
      LEFT JOIN 
        (SELECT recipient_osid, SUM(crp_contrib_individual_to_candidate.amount) as ind_contrib_total 
         FROM crp_contrib_individual_to_candidate
         WHERE crp_interest_group_osid=? AND cycle=? AND recipient_osid=? AND crp_contrib_individual_to_candidate.contrib_type IN ('10', '11', '15 ', '15', '15E', '15J', '22Y')
         GROUP BY recipient_osid) 
        top_recips_ind ON people.osid=top_recips_ind.recipient_osid
      LEFT JOIN
        (SELECT recipient_osid, SUM(crp_contrib_pac_to_candidate.amount) as pac_contrib_total 
         FROM crp_contrib_pac_to_candidate
         WHERE crp_contrib_pac_to_candidate.crp_interest_group_osid=? AND crp_contrib_pac_to_candidate.cycle=? AND crp_contrib_pac_to_candidate.recipient_osid=?
         GROUP BY crp_contrib_pac_to_candidate.recipient_osid) 
        top_recips_pac ON people.osid=top_recips_pac.recipient_osid
     WHERE people.id=?
     ORDER BY contrib_total DESC
     LIMIT 1", osid, Settings.current_opensecrets_cycle, person.osid, osid, Settings.current_opensecrets_cycle, person.osid, person.id])
     
     return p.first.nil? ? 0 : p.first.attributes['contrib_total'].to_i
  end
end
