xml.instruct!

xml.feed "xmlns" => "http://www.w3.org/2005/Atom" do

  if @commentary_type == 'topblog'
    title_for_type = 'Highest Rated Blog'
  elsif @commentary_type == 'topnews'
    title_for_type = 'Highest Rated News'
  else
    title_for_type = @commentary_type.capitalize
  end
    
  xml.title   "Open Congress : #{title_for_type} Articles for #{@person.name}"
  xml.link    "rel" => "self", "href" => url_for(:only_path => false, :controller => 'people', :action => "atom_#{@commentary_type.pluralize}", :id => @person )
  xml.link    "rel" => "alternate", "href" => url_for(:only_path => false, :controller => 'people', :action => @commentary_type.pluralize, :id => @person )
  xml.updated @commentaries.first.date.strftime("%Y-%m-%dT%H:%M:%SZ") if @commentaries.any?
  xml.author  { xml.name "opencongress.org" }
  xml.id      "tag:opencongress.org,2007:/person/#{@commentary_type}/#{@person.id}"
    
  @commentaries.each do |c|
    commentary_atom_entry(xml, c)
  end
end