module RollCallHelper
  def person_type
    case @roll_call.chamber
      when 'House' then 'Representative'
      when 'Senate' then 'Senator'
    end
  end
  
  def aye_breakdown(display = 'html')
    breakdown('+', display)
  end
  
  def nay_breakdown(display = 'html')
    breakdown('-', display)
  end
  
  def abstain_breakdown(display = 'html')
    breakdown('0', display)
  end
  
  def vote_name(vote)
    vote_names = { '+' => 'Aye', "-" => 'Nay', "0" => 'Abstain' }
    return vote_names[vote]
  end
  
  def breakdown(breakdown_type, display)
    vote_names = { '+' => 'Aye', "-" => 'Nay', "0" => 'Abstain' }
    vote_methods = { '+' => 'ayes', "-" => 'nays', "0" => 'abstains' }
    
    votes = @roll_call.roll_call_votes.select { |rcv| rcv.vote == breakdown_type }
    
    democrat_votes = votes.select { |rcv| rcv.person.party == 'Democrat' if rcv.person }
    republican_votes = votes.select { |rcv| rcv.person.party == 'Republican' if rcv.person }
    out = "("
    
    
    if display == 'plain'
      out += "Democrat: #{democrat_votes.size}; Republican: #{republican_votes.size}"
    else
      out += "<span style='color: #888;'>Democrat:</span> <a href='/roll_call/sublist/#{@roll_call.id}?party=Democrat&vote=#{vote_names[breakdown_type]}'>#{democrat_votes.size}</a>;"
      out += " <span style='color: #888;'>Republican:</span> <a href='/roll_call/sublist/#{@roll_call.id}?party=Republican&vote=#{vote_names[breakdown_type]}'>#{republican_votes.size}</a>"
    end
    
    if (votes.size - democrat_votes.size - republican_votes.size) > 0
      if display == 'plain'
        out += "; Other: #{votes.size - democrat_votes.size - republican_votes.size}"
      else
        out += "; <span style='color: #888;'>Other:</span> <a href='/roll_call/sublist/#{@roll_call.id}?party=Other&vote=#{vote_names[breakdown_type]}'>#{votes.size - democrat_votes.size - republican_votes.size}</a>"
      end
    end
    
    if display == 'plain'
      out += ")"
    else
      out += (votes.size == @roll_call.send(vote_methods[breakdown_type])) ? ")" : ")**"
    end
    
    out   
  end
  

  def roll_call_master_sublists(person_type)
    # let's just define this again, cause it's fun, right? sigh.
    vote_names = { '+' => 'Aye', "-" => 'Nay', "0" => 'Abstain' }
    
    out = ""
    
    vote_names.keys.each do |vote_type|
      votes = @roll_call.roll_call_votes.select { |rcv| (rcv.vote == vote_type && rcv.person) }
      out += "<script type=\"text/javascript\">$j().ready(function(){$j('##{vote_names[vote_type]}_All').jqm();});</script>"
      out += "<div id='#{vote_names[vote_type]}_All' class='jqmWindow scrolling'>\n"
      out += "<div class='ie'><a href='#' class='jqmClose'>Close</a></div><h4>#{person_type}s Voting '#{vote_names[vote_type]}'</h4>\n"
      votes.each { |v| out += "#{link_to_person v.person}<br />\n" }
      out += "</div>\n"
    end
    
    out
  end
  
  
  def roll_call_sublists_by_vote_type(vote_type, roll_call)
    # let's just define this again, cause it's fun, right? sigh.
    vote_names = { '+' => 'Aye', "-" => 'Nay', "0" => 'Abstain' }
    parties = ['Democrat', 'Republican', 'Other' ]
    
    out = ""
    
    parties.each do |party|
      unless party == 'Other'
        votes = roll_call.roll_call_votes.select { |rcv| (rcv.vote == vote_type && rcv.person && rcv.person.party == party) }
      else
        votes = roll_call.roll_call_votes.select { |rcv| (rcv.vote == vote_type && rcv.person && rcv.person.party != 'Democrat' && rcv.person.party != 'Republican') }
      end
      
      out += %Q{<script type="text/javascript">$j().ready(function(){$j('##{party}_#{vote_names[vote_type]}').jqm();});</script>
      <div id="#{party}_#{vote_names[vote_type]}" class="jqmWindow scrolling">
      <div class="ie"><a href="#" class="jqmClose"><span>Close</span></a></div><h4>#{party}s Voting '#{vote_names[vote_type]}'</h4>}
      votes.each { |v| out += "#{link_to_person v.person}<br />\n" }
      out += "</div>\n"
    end
    
    out
  end
  
  def numeric_percentage(roll_call)
    case roll_call.required
      when '1/2' then "(50%)"
      when '2/3' then "(66%)"
      when '3/5' then "(60%)"
    end
  end
end
