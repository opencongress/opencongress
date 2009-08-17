xml.instruct!

xml.feed "xmlns" => "http://www.w3.org/2005/Atom" do

  xml.title   "Open Congress : Top 20 Most Viewed Issues"
  xml.link    "rel" => "self", "href" => url_for(:only_path => false, :controller => 'issues', :action => 'atom_top20' )
  xml.link    "rel" => "alternate", "href" => url_for(:only_path => false, :controller => 'issues', :action => 'by_most_viewed' )
  xml.updated @issues.first.stats.entered_top_viewed.strftime("%Y-%m-%dT%H:%M:%SZ") if @issues.any?
  xml.author  { xml.name "opencongress.org" }
  xml.id      "tag:opencongress.org,2007:/issue_top20"

  @issues.each do |i|
    xml.entry do
      xml.title   i.term
      xml.link    "rel" => "alternate", "href" => url_for(:only_path => false, :controller => 'issue', :action => 'show', :id => i)
      xml.id      i.atom_id_as_entry
      xml.updated i.stats.entered_top_viewed.strftime("%Y-%m-%dT%H:%M:%SZ")
      xml.content "type" => "html" do
        xml.text! i.term
      end
    end
  end
end