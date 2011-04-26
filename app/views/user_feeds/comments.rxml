xml.instruct!

xml.feed "xmlns" => "http://www.w3.org/2005/Atom" do

  xml.title   "Open Congress : #{@title}" 
  xml.link    "rel" => "self", "href" => url_for(:only_path => false, :controller => 'profile', :action => params[:action], :login => params[:login] )
  xml.updated @comments.first.created_at.strftime("%Y-%m-%dT%H:%M:%SZ") if @comments.any?
  xml.author  { xml.name "opencongress.org" }

  @comments.each do |c|
    commentable = Object.const_get(c.commentable_type).find_by_id(c.commentable_id)
    xml.entry do
      xml.title   "Comment: " + c.commentable_type.to_s + " : " + commentable.to_param.to_s
      if c.commentable_type == "Bill"
        xml.link    "rel" => "alternate", "href" => bill_url(commentable.to_param)
      end
      xml.updated c.updated_at.strftime("%Y-%m-%dT%H:%M:%SZ")
      xml.content "type" => "html" do
        xml.text! c.comment
      end
    end
  end
end
