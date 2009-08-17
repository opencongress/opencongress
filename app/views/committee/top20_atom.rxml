xml.instruct!

xml.feed "xmlns" => "http://www.w3.org/2005/Atom" do

  xml.title   "Open Congress : Top 20 Most Viewed Committees"
  xml.link    "rel" => "self", "href" => url_for(:only_path => false, :controller => 'committee', :action => 'atom_top20' )
  xml.link    "rel" => "alternate", "href" => url_for(:only_path => false, :controller => 'committee', :action => 'by_most_viewed' )
  xml.updated @comms.first.stats.entered_top_viewed.strftime("%Y-%m-%dT%H:%M:%SZ") if @comms.any?
  xml.author  { xml.name "opencongress.org" }
  xml.id      "tag:opencongress.org,2007:/committee_top20"


  @comms.each do |c|
    xml.entry do
      if c.subcommittee_name.nil? || c.subcommittee_name.empty?
        xml.title   "#{c.name}"
      else
        xml.title   "#{c.name} - #{c.subcommittee_name}"
      end
      
      xml.link    "rel" => "alternate", "href" => url_for(:only_path => false, :controller => 'committee', :action => 'show', :id => c)
      xml.id      c.atom_id_as_entry
      xml.updated c.stats.entered_top_viewed.strftime("%Y-%m-%dT%H:%M:%SZ")
      xml.content "type" => "html" do
        if c.subcommittee_name.nil? || c.subcommittee_name.empty?
          xml.text!   "#{c.name}"
        else
          xml.text!   "#{c.name} - #{c.subcommittee_name}"
        end
      end
    end
  end
end