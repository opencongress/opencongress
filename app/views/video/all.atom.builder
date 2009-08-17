xml.instruct!

xml.feed "xmlns" => "http://www.w3.org/2005/Atom" do
  xml.title   "Open Congress : Latest Videos"
  xml.link    "rel" => "self", "href" => url_for(:controller => 'video', :action => 'atom', :only_path => false)
  xml.link    "rel" => "alternate", "href" => url_for(:only_path => false, :controller => 'video', :action => 'all')
  xml.updated @videos.first.created_at.strftime("%Y-%m-%dT%H:%M:%SZ") if @videos.any?
  xml.author  { xml.name "opencongress.org" }
  xml.id      "tag:opencongress.org,#{Time.now.year}:/video/rss"

  @videos.each do |v|
    xml.entry do 
      xml.title   v.title
      xml.link    "rel" => "alternate", "href" => v.url
      xml.id      v.atom_id_as_entry
      
      xml.updated v.updated_at.strftime("%Y-%m-%dT%H:%M:%SZ")
      xml.content "type" => "html" do
        xml.text! "#{v.url}<br /><br />#{v.description}"
      end
    end
  end
end