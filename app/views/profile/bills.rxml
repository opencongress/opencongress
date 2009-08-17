xml.instruct!

xml.feed "xmlns" => "http://www.w3.org/2005/Atom" do

  xml.title   "Open Congress : #{@title}" 
  xml.link    "rel" => "self", "href" => url_for(:only_path => false, :controller => 'profile', :action => params[:action], :login => params[:login] )
  xml.updated @items.first.datetime.strftime("%Y-%m-%dT%H:%M:%SZ") if @items.any?
  xml.author  { xml.name "opencongress.org" }

  @items.each do |action|
    bill_action_atom_entry(xml, action)
  end
end
