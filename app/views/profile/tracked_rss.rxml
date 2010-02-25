xml.instruct!
xml.feed "xmlns" => "http://www.w3.org/2005/Atom" do

  xml.title   "Open Congress : #{@title}" 
  xml.link    "rel" => "self", "href" => url_for(:only_path => false, :controller => 'profile', :action => params[:action], :login => params[:login] )
  xml.updated @items.first.rss_date.strftime("%Y-%m-%dT%H:%M:%SZ") if @items.any?
  xml.author  { xml.name "opencongress.org" }

  @items[0..19].each do |i|
      case i.class.name
      when 'Bill'
      xml.entry do

        xml.title   i.sponsor.name + 'Introduced Bill: ' + i.typenumber
        xml.link    "rel" => "alternate", "href" => bill_url(i)
        xml.id      i.atom_id_as_entry
        xml.updated Time.at(i.introduced).strftime("%Y-%m-%dT%H:%M:%SZ")
        xml.content "type" => "html" do
          xml.text! i.title_official
        end
      end
      when 'RollCallVote'
      xml.entry do

        xml.link    "rel" => "alternate", "href" => url_for(:only_path => false, :controller => 'roll_call', :action => 'show', :id => i.roll_call)
        xml.id      i.atom_id
        xml.updated i.roll_call.date.strftime("%Y-%m-%dT%H:%M:%SZ")
        if i.roll_call.bill
          xml.title   "Vote: '" + i.to_s + "' regarding " + i.roll_call.bill.typenumber
          xml.content "type" => "html" do
            xml.text! i.person.name + " voted '" + i.to_s + "' on the question: " + 
              (link_to i.roll_call.question, :only_path => false, :controller => 'roll_call', :action => 'show', :id => i.roll_call) +
                      " regarding #{link_to i.roll_call.bill.title_full_common, bill_url(i.roll_call.bill)}"
          end
        else
          xml.title   "Vote: '" + i.to_s + "' on the question " + i.roll_call.question
          xml.content "type" => "html" do
            xml.text! i.person.name + " voted '" + i.to_s + "' on the question: " + 
              (link_to i.roll_call.question, :only_path => false, :controller => 'roll_call', :action => 'show', :id => i.roll_call)
          end
        end
      end
      when 'BillAction'
      bill_action_atom_entry(xml, i)
    end
        
           
  end
end
