xml.instruct!

xml.feed "xmlns" => "http://www.w3.org/2005/Atom" do

  xml.title   "Open Congress : Major Bill Actions in " + @subject.term
  xml.link    "rel" => "self", "href" => url_for(:only_path => false, :controller => 'issue', :action => 'atom', :id => @subject )
  xml.link    "rel" => "alternate", "href" => url_for(:only_path => false, :controller => 'issue', :action => 'show', :id => @subject )
  xml.updated @actions.first.datetime.strftime("%Y-%m-%dT%H:%M:%SZ") if @actions.any?
  xml.author  { xml.name "opencongress.org" }
  xml.id      @subject.atom_id_as_feed

  @actions.each do |a|
    bill_action_atom_entry(xml, a)
  end
end
