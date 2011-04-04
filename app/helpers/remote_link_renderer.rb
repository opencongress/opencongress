class RemoteLinkRenderer < WillPaginate::ViewHelpers::LinkRenderer
  def prepare(collection, options, template)
    @remote = options.delete(:remote) || {}
    super
  end
  
  
  protected
    def page_number(page)
      unless page == current_page
        link(page, page, :rel => rel_value(page))
      else
        tag(:em, tag(:span, page))
      end
    end


    def previous_or_next_page(page, text, classname)
      if page
        link(text, page, :class => classname)
      else
        tag(:span, tag(:span, text), :class => classname + ' disabled')
      end
    end
          
          
          
  private
    def link(text, target, attributes = {})
      if target.is_a? Fixnum
        attributes[:rel] = rel_value(target)
        target = url(target)
      end
      attributes[:href] = target
      #link_to_remote("<span>#{text}</span>", {:url => target, :method => :get}.merge(@remote))
      attributes['data-remote'] = 'true'
      attributes['data-method'] = 'post'
      tag(:a, "<span>#{text}</span>".html_safe, attributes)
    end
    
    
    
    
    # def page_link(page, text, attributes = {})
    #   @template.link_to_remote("<span>#{text}</span>", {:url => url_for(page), :method => :get}.merge(@remote))
    # end
    # 
    # def page_span(page, text, attributes = {})
    #   @template.content_tag :span, "<span>#{text}</span>", attributes
    # end                                         
end