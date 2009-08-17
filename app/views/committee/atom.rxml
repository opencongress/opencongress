xml.instruct!

xml.feed "xmlns" => "http://www.w3.org/2005/Atom" do

  xml.title   "Open Congress : #{@committee_name} - Major Bill Actions"
  xml.link    "rel" => "self", "href" => url_for(:only_path => false, :controller => 'committee', :action => 'atom', :id => @committee )
  xml.link    "rel" => "alternate", "href" => url_for(:only_path => false, :controller => 'committee', :action => 'show', :id => @committee )
  xml.updated @actions.first.datetime.strftime("%Y-%m-%dT%H:%M:%SZ") if @actions.any?
  xml.author  { xml.name "opencongress.org" }
  xml.id      @committee.atom_id_as_entry
  

  @actions.each do |a|         
    bill_action_atom_entry(xml, a)
  end
end
