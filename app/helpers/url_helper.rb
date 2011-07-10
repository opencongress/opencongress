module UrlHelper

	def link_to_shown_url(url, opts = {})
	  link_to url, url, opts
  end
	
  def link_to_item(item, attribute, action, controller = nil, show_views = false, trunc = false)
    link_text = ""
    link_text += trunc ? "<span class=\"title\">#{truncate(item.send(attribute), :length => trunc)}</span>".html_safe :
                         "<span class=\"title\">#{item.send(attribute)}</span>".html_safe
    if item.kind_of? Bill
      link_text +=  "<span class=\"date\"><span>#{temp_url_strip(item.status)}</span>#{item.last_action.formatted_date if item.last_action}</span>".html_safe
    end
    link_text += show_views ? "<span class=\"views_count\"><span>#{item.views(Settings.default_count_time) if show_views}</span> views</span>".html_safe : ""

    if item.kind_of? Bill
      controller ? link_to(link_text.html_safe, { :action => action, :controller => controller, :id => item.ident }) :
                   link_to(link_text.html_safe, { :action => action, :id => item.ident })
    else
      controller ? link_to(link_text.html_safe, { :action => action, :controller => controller, :id => item }) :
                   link_to(link_text.html_safe, { :action => action, :id => item })
    end
  end

  def link_to_person(person)
    link_to person.name, :controller => 'people', :action => 'show', :id => person
  end
  
  def link_to_bill(bill)
    link_to bill.title_full_common, bill_url(bill)
  end

  def url_for_object(object)
    if object.kind_of? Bill
      bill_url(object)
    elsif object.kind_of? Person
      person_url(object)
    elsif object.kind_of? Subject
      issue_url(object)
    else
      url_for :controller => object.class.name.downcase, :action => 'show', :id => object
    end
  end
 
  def url_for_internal(link)
    case link.notebookable.type.to_s
    when 'Bill'
      bill_url(link.notebookable)
    when 'Subject'
      issue_url(link.notebookable.to_param)
    when 'Person'
      person_url(link.notebookable.to_param)
    when 'ContactCongressLetter'
      url_for contact_congress_letter_path(link.notebookable)
    when 'Commentary'
      link.url
    end    
  end

  def link_to_internal(link)    
    link_to link.title, url_for_internal(link)
  end


  def server_url_for(options = {})
    url_for options.update(:only_path => false)
  end
  
  
  def with_subdomain(subdomain)  
    subdomain = (subdomain || '')
    subdomain += '.' unless subdomain.empty?

    # Using HOST here instead of request.domain because
    # HOST can be 'staging.opengovernment.org' whereas request.domain in that case
    # would be simply 'opengovernment.org'
    [subdomain, HOST, request.port_string].join  
  end
  
  def url_for(options = nil)    
    if options.kind_of?(Hash) && options.has_key?(:subdomain)  
      options[:host] = with_subdomain(options.delete(:subdomain))  
    end

    super  
  end

end
