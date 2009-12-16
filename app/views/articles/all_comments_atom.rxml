xml.instruct!

xml.feed "xmlns" => "http://www.w3.org/2005/Atom" do

  xml.title   "Open Congress : All Blog Comments"
  xml.link    "rel" => "self", "href" => url_for(:only_path => false, :controller => 'articles', :action => 'all_comments_atom')
  xml.updated (@comments.first.created_at.strftime("%Y-%m-%dT%H:%M:%SZ")) if @comments.any?
  xml.author  { xml.name "opencongress.org" }
  xml.id      "tag:opencongress.org,2007:/articles/all_comments"

  @comments.each do |c|
    xml.entry do
      xml.title   "New comment by #{c.name} regarding #{c.article.title}"
      xml.link    "rel" => "alternate", "href" => article_url(c.article)
      xml.updated (c.created_at.strftime("%Y-%m-%dT%H:%M:%SZ"))
      xml.id      c.atom_id
      xml.author  { xml.name c.name }
      xml.content "type" => "html" do
        xml.text! "Comment regarding #{link_to(c.article.title, article_url(c.article))}" +
                  "<br><br>#{c.comment}"
      end
    end
  end
end
