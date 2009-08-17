xml.instruct!

xml.feed "xmlns" => "http://www.w3.org/2005/Atom" do

  xml.title   "Open Congress : Recent Votes"
  xml.link    "rel" => "self", "href" => url_for(:only_path => false, :controller => 'roll_call', :action => 'atom' )
  xml.link    "rel" => "alternate", "href" => url_for(:only_path => false, :controller => 'roll_call', :action => 'all' )
  xml.updated @rolls.first.date.strftime("%Y-%m-%dT%H:%M:%SZ") if @rolls.any?
  xml.author  { xml.name "opencongress.org" }
  xml.id      "tag:opencongress.org,2007/roll_call_all"
  
  @rolls.each do |r|
    xml.entry do
      xml.title   r.chamber + ': ' + r.question
      xml.link    "rel" => "alternate", "href" => url_for(:only_path => false, :controller => 'roll_call', :action => 'show', :id => r)
      xml.id      r.atom_id
      xml.updated r.date.strftime("%Y-%m-%dT%H:%M:%SZ")
      xml.content "type" => "html" do
        xml.text! 'Date: ' + r.date.strftime("%B %d, %Y") + "<br />"
        xml.text! 'Chamber: ' + r.chamber + "<br />"
        xml.text! 'Type: ' + r.roll_type + "<br />"
        xml.text! 'Question: ' + r.question + "<br />"
        xml.text! 'Ayes: ' + r.ayes.to_s + "<br />"
        xml.text! 'Nays: ' + r.nays.to_s + "<br />"
        xml.text! 'Result: ' + r.result + "<br /><br />"
        
        xml.text! link_to('Roll Call Details', :only_path => false, :controller => 'roll_call', :action => 'show', :id => r)
      end
    end
  end
end
