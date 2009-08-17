class SpanLinkRenderer < WillPaginate::LinkRenderer
  
protected
  def page_link(page, text, attributes = {})
    @template.link_to "<span>#{text}</span>", url_for(page), attributes
  end

  def page_span(page, text, attributes = {})
    @template.content_tag :span, "<span>#{text}</span>", attributes
  end
                                            
end