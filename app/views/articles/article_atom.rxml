xml.instruct!

xml.feed "xmlns" => "http://www.w3.org/2005/Atom" do

  xml.title   "Open Congress : Comments on '#{@article.title}'"
  xml.link    "rel" => "self", "href" => url_for(:only_path => false, :controller => 'articles', :action => 'article_atom', :id => @article )
  xml.link    "rel" => "alternate", "href" => article_url(@article)
  xml.updated (@article.comments.first.created_at.strftime("%Y-%m-%dT%H:%M:%SZ")) if @article.comments.any?
  xml.author  { xml.name "opencongress.org" }
  xml.id      @article.atom_id_as_feed

  @article.comments.each do |c|
    xml.entry do
      xml.title   "New comment by #{c.name}"
      xml.link    "rel" => "alternate", "href" => article_url(@article)
      xml.updated (c.created_at.strftime("%Y-%m-%dT%H:%M:%SZ"))
      xml.id      c.atom_id
      xml.author  { xml.name c.name }
      xml.content "type" => "html" do
        xml.text! c.comment
      end
    end
  end
end
