xml.instruct!

xml.feed "xmlns" => "http://www.w3.org/2005/Atom" do

  xml.title   "Open Congress : Blog"
  xml.link    "rel" => "self", "href" => url_for(:only_path => false, :controller => 'articles', :action => 'atom')
  xml.link    "rel" => "alternate", "href" => url_for(:only_path => false, :controller => 'blog')
  xml.updated @articles.first.created_at.strftime("%Y-%m-%dT%H:%M:%SZ") if @articles.any?
  xml.author  { xml.name "opencongress.org" }
  xml.id      "tag:opencongress.org,2007:/blog"
  
  @articles.each do |a|
    xml.entry do
      xml.title   a.title
      xml.link    "rel" => "alternate", "href" => article_url(a)
      xml.id      a.atom_id_as_entry
      xml.updated a.created_at.strftime("%Y-%m-%dT%H:%M:%SZ")
      xml.author  { xml.name a.user.full_name } if a.user.full_name
      xml.content "type" => "html" do
        xml.text! a.content_rendered
      end
    end
  end
end
