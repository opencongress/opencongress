module PeopleHelper
  def roles_table(person)
    table_top = '<table class="simple-table">
      <tr>
        <th scope="col">Term Start</th>
        <th scope="col">Term End</th>
        <th scope="col">Role&nbsp;&nbsp;&nbsp;</th>
        <th scope="col">State&nbsp;</th>
        <th scope="col">Party&nbsp;</th>
      </tr>'
    
    table_bottom = "</table>"
    
    first_role = person.roles_sorted.first
    first_role_row = "<tr>
      <td>#{ first_role.startdate.year }</td>
      <td>#{ first_role.enddate.year }</td>
      <td>#{ first_role.display_type }</td>
      <td>#{ first_role.state }</td>
      <td>#{ first_role.party }</td>
    </tr>"
    
    
    all_roles = ""
    person.roles_sorted.each do |role|
      all_roles += "<tr>
        <td>#{ role.startdate.year }</td>
        <td>#{ role.enddate.year }</td>
        <td>#{ role.display_type }</td>
        <td>#{ role.state }</td>
        <td>#{ role.party }</td>
        </tr>"
    end 
      
    if person.roles_sorted.size == 1
      "#{table_top}#{first_role_row}#{table_bottom}"
    else  
      "<span id='gossip_more'>#{table_top}#{first_role_row}<tr><td colspan=5><a href='javascript:replace("  +
      "\"gossip_extra\",\"gossip_more\")' class='arrow'>See All #{person.roles_sorted.size} Terms</a></td></tr>#{table_bottom}</span>" +
      "<span id=\"gossip_extra\" style='display: none'>#{table_top}#{all_roles}<tr><td colspan=5><a href='javascript:replace("  +
      "\"gossip_more\",\"gossip_extra\")' class='arrow-hide'>Hide Terms</a></td></tr>#{table_bottom}</span>"
    end
  end
	
	def person_type_small(person_type)
	  case person_type.downcase
    when /^rep/
      "Rep."
    else
      "Senator"
    end
  end
	
  def top_voting_similarities
	  total_people = (@person.title == "Sen.") ? 100 : 440
    
    stats = @person.person_stats
    if stats
      output = "<div id='voting-similarities'>"
      if stats.votes_most_often_with || stats.opposing_party_votes_most_often_with
        output += "<ul class='votes_with'><li><em>Most often votes with:</em></li> "                     
        
        if stats.votes_most_often_with
          output += "<li class='#{@person.party}'>" + (link_to stats.votes_most_often_with.title_full_name, { :controller => 'people', :action => 'show', :id => stats.votes_most_often_with }) +       
          "</li>"                     
        end                           
      
        if @person.belongs_to_major_party?
          if stats.opposing_party_votes_most_often_with
            output += "<li class='#{@person.opposing_party}'>" + 
            (link_to stats.opposing_party_votes_most_often_with.title_full_name, { :controller => 'people', :action => 'show', :id => stats.opposing_party_votes_most_often_with }) + 
            "</li>"
          end
        end
      output += "</ul>"
    end
    
    if stats.votes_least_often_with || stats.same_party_votes_least_often_with
      output += "<ul class='votes_least'><li><em>Least often votes with:</em></li>"
      
        if stats.same_party_votes_least_often_with
          output += "<li class='#{@person.party}'>" + 
          (link_to stats.same_party_votes_least_often_with.title_full_name,{ :controller => 'people', :action => 'show', :id => stats.same_party_votes_least_often_with }) +
          "</li>"
        end
      
        if @person.belongs_to_major_party?
          if stats.votes_least_often_with
            output += "<li class='#{@person.opposing_party}'>" + 
            (link_to stats.votes_least_often_with.title_full_name, { :controller => 'people', :action => 'show', :id => stats.votes_least_often_with }) + 
            "</li>"
          end
        end
      output += "</ul>"
    end
      
    if stats.party_votes_percentage || stats.abstains_percentage   
      output += "<ul class='votes_percent'>"
    
      if stats.party_votes_percentage
        output += "<li class='pie_votes'>Votes with party #{@person.person_stats.party_votes_percentage.round}%</li>"
      end
      
      if stats.abstains_percentage
        output += "<li class='abstains'>Abstains: #{@person.person_stats.abstains_percentage.round}%</li>"
      end
    
      output += "</ul>"
    end
    output += "</div>"
    output
    end
  end
	
	def sponsored_bill_stats
	  total_people = (@person.title == "Sen.") ? 100 : 440
	  
	  output = ""
	  unless @person.person_stats.sponsored_bills.nil?
  	  output += "<li>" +
  	          link_to(@person.person_stats.sponsored_bills, {:controller => 'people', :action => 'bills', :id => @person}) +
  	          " Sponsored Bills (Ranks #{@person.person_stats.sponsored_bills_rank} of #{total_people}) "
       unless @person.person_stats.sponsored_bills_passed.nil?
         output += @person.person_stats.sponsored_bills_passed.to_s +
         " Passed (Ranks #{@person.person_stats.sponsored_bills_passed_rank} of #{total_people})</li>"
       end
    else
      output += "<li>No Sponsored Bills</li>"
    end
    
    unless @person.person_stats.cosponsored_bills.nil?
      output += "<li>" +
          	  link_to(@person.person_stats.cosponsored_bills, {:controller => 'people', :action => 'bills', :id => @person}) +
          	  " Co-Sponsored Bills (Ranks #{@person.person_stats.cosponsored_bills_rank} of #{total_people}) "
      unless @person.person_stats.cosponsored_bills_passed.nil?
        output += @person.person_stats.cosponsored_bills_passed.to_s +
            	  " Passed (Ranks #{@person.person_stats.cosponsored_bills_passed_rank} of #{total_people})" 
      end        
      output += "</li>"
    else
      output += "<li>No Co-Sponsored Bills</li>"
    end
    

    return output.blank? ? "Data unavailable at this time." : output
	end

	
	def alphalist(person)
		out = "<div class='alphabet_links'>"
		alpha = []
		letter = ''
		person.each do |person|
			if person.lastname.to_s[0,1] != letter
				letter = person.lastname.to_s[0,1]
				alpha << letter
			end
		end
		alpha.each do |x|
			out += "<a href='\##{x}'>#{x}</a>"
			unless x == alpha.last
				out += "&middot;"
			end
		end
		out += "</div>"
	end

	def rc_compare(vo, xml = false)
	  logger.info "COMPARING: #{vo.id}"
    vote1 = RollCallVote.find_by_roll_call_id_and_person_id(vo.id,@person1.id)
    vote2 = RollCallVote.find_by_roll_call_id_and_person_id(vo.id,@person2.id)
    
    if vote1.nil? && !vote2.nil?
      clash = "yes"
      vote1 = "Not Voting"
    elsif vote2.nil? && !vote1.nil?
      clash = "yes"
      vote2 = "Not Voting"
    elsif vote2.nil? && vote1.nil?
      clash="no"
    else
      if vote1.vote != vote2.vote  
        clash = "no" 
      else 
        clash = "yes"
      end
    end
    unless xml == true
     "<td class='#{clash}'><table class='compin'><tr><td class='call'><b>Roll Call&nbsp;" + link_to(vo.number, :controller => :roll_call, :action => :show, :id => vo.id) + "</b></td><td class='peeps'>#{@person1.lastname}:&nbsp;<font class='#{vote1}'>#{vote1}</b></td><td class='peeps'>#{@person2.lastname}:&nbsp;<font class='#{vote2}'>#{vote2}</b></td></tr></table></td>" 
    else
      xml_builder = Builder::XmlMarkup.new
      xml_builder.person1 { |xml|
         xml.stong(vote1)
      }
      xml_builder.person2 { |xml|
         xml.stong(vote2)
      }      
    end

  end
  
end
