class RemoteLinkRenderer < WillPaginate::LinkRenderer
  def prepare(collection, options, template)
    @remote = options.delete(:remote) || {}
    super
  end

protected
  def page_link(page, text, attributes = {})
    @template.link_to_remote("<span>#{text}</span>", {:url => url_for(page), :method => :get}.merge(@remote))
  end
  
  def page_span(page, text, attributes = {})
    @template.content_tag :span, "<span>#{text}</span>", attributes
  end
end

