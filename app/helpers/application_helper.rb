# Methods added to this helper will be available to all templates in
# the application.
module ApplicationHelper

  def split_list(list, attribute, item_limit, action, controller = nil, show_views = false, trunc = false)
    item_limit = list.size if item_limit > list.size
    list.empty? ? [] :
      [
      list[0...item_limit].map {|l| 
        "<li>" + link_to_item(l, attribute, action,
        controller, show_views, trunc) + "</li>" }.join,
      list[item_limit...list.size].map {|l| "<li>" + link_to_item(l, attribute, action,
        controller, trunc) + "</li>"}.join
    ]
  end
	
  def link_to_item(item, attribute, action, controller = nil, show_views = false, trunc = false)
    link_text = ""
    link_text += trunc ? "<span class=\"title\">#{truncate(item.send(attribute), :length => trunc)}</span>" :
                         "<span class=\"title\">#{item.send(attribute)}</span>"
    if item.kind_of? Bill
      link_text +=  "<span class=\"date\"><span>#{temp_url_strip(item.status)}</span>#{item.last_action.formatted_date if item.last_action}</span>"
    end
    link_text += show_views ? "<span class=\"views_count\"><span>#{item.views(DEFAULT_COUNT_TIME) if show_views}</span> views</span>" : ""

    if item.kind_of? Bill
      controller ? link_to(link_text, { :action => action, :controller => controller, :id => item.ident }) :
                   link_to(link_text, { :action => action, :id => item.ident })
    else
      controller ? link_to(link_text, { :action => action, :controller => controller, :id => item }) :
                   link_to(link_text, { :action => action, :id => item })
    end
  end
  
  def partial_list(list, attribute, item_limit, text_for_more, extra_id,
    more_id, action, controller, show_views = false, trunc = false)
    parts = split_list(list, attribute, item_limit, action, controller, show_views, trunc)
    return "" if parts.empty?
    return parts[0] if parts[1].empty?
    parts[0] +
      "<span id=\"#{more_id}\"> <li class=\"small\"><a href=\"javascript:replace('#{extra_id}','#{more_id}')\" class=\"more_link\">#{text_for_more}</a></li></span><span style=\"display: none\" id=\"#{extra_id}\">#{parts[1]}</span>"
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
  
  def breadcrumb
    if @breadcrumb
      @breadcrumb[0] = { 'text' => "HOME", 'url' => "/" }  
      @breadcrumb = @breadcrumb.sort
            
      crumbs = []
      @breadcrumb.each do |index, link_hash|
        crumbs << link_to(link_hash['text'], link_hash['url'])
      end
    else
      # try to figure out breadcrumb as best as we can
      klass = controller.class
      home_link = link_to "HOME", "/"
      controller_name = klass.controller_path.singularize.pluralize
      controller_link = link_to controller_name.capitalize, :controller => klass.controller_name 
      if controller.params[:id].nil?
        action_link = link_to controller.action_name.capitalize, :controller => klass.controller_name, :action => controller.action_name
      else
        id = controller.params[:id].sub(/^\d+_/, "")
        action_link = link_to id, :controller => klass.controller_name, :action => controller.action_name,  :id => controller.params[:id]
      end
    
      crumbs = [home_link, controller_link, action_link]
    end
    
    styled_crumbs = []
    crumbs.each do |c|
      unless c == crumbs.last
        styled_crumbs << "<em>" + c + "</em> "
      else
        styled_crumbs << "<strong>" + c + "</strong>"
      end
    end
    
    "You are here : " + styled_crumbs.join("<span>&gt;</span>")
  end

  def pagination_nav(pages, options = {})
    out = ""
    out += link_to "Previous Page", { :page => pages.current.previous }.merge(options), :class => 'arrow-left' if pages.current.previous
    out += " #{oc_pagination_links(pages, options)} "
    out += link_to "Next page", { :page => pages.current.next }.merge(options), :class => 'arrow' if pages.current.next
    return out
  end
  
  unless const_defined?(:DEFAULT_OPTIONS)
    DEFAULT_OPTIONS	=	{ 
      :name => :page, 
      :window_size => 2, 
      :always_show_anchors => true, 
      :link_to_current_page => false, 
      :params => {}
    }
  end
  
  def oc_pagination_links(paginator, options={}, html_options={})
    name = options[:name] || DEFAULT_OPTIONS[:name]
    params = (options[:params] || DEFAULT_OPTIONS[:params]).clone
        
    oc_pagination_links_each(paginator, options) do |n, first, last|
      params[name] = n
      link_to("[#{first.to_s}-#{last.to_s}]", params, html_options)
    end
  end
  
  def blog_excerpt_with_more(article)
    content = article.content_rendered
    
    if content.length <= 400
      content
    else
      text_no_html = content.gsub(/<\/?[^>]*>/, "")

      space = text_no_html.index(' ', 400)
            
      "#{text_no_html[0..space]} " + 
      link_to('More...', article_url(article), :class => 'arrow biglinks')
    end
  end
  def truncate_string(str, length)
    if str.length <= length
      str
    else
      "#{str[0..length]}..."
    end
  end
  
  def truncate_more(str, length)
    if str.length <= length
      str
    else
      random_name = rand(100)
      first_half = "#{str[0..length]}" + link_to_function("...More", "Element.hide('tl_#{random_name}');Element.show('tm_#{random_name}');", :id => "tl_#{random_name}", :class => "arrow biglinks")
      second_half = "<span style=\"display:none;\" id=\"tm_#{random_name}\">#{str[length+1..str.length]}</span>"
      return first_half + second_half
    end
  end
  
  def oc_pagination_links_each(paginator, options)
    options = DEFAULT_OPTIONS.merge(options)
    link_to_current_page = options[:link_to_current_page]
    always_show_anchors = options[:always_show_anchors]

    current_page = paginator.current_page
    window_pages = current_page.window(options[:window_size]).pages
    return if window_pages.length <= 1 unless link_to_current_page
         
    first, last = paginator.first, paginator.last
         
    html = ''
    if always_show_anchors and not (wp_first = window_pages[0]).first?
      html << yield(first.number, first.first_item, first.last_item)
      html << ' ... ' if wp_first.number - first.number > 1
      html << ' '
    end
           
    window_pages.each do |page|
      if current_page == page && !link_to_current_page
        html << "[#{page.first_item.to_s}-#{page.last_item.to_s}]"
      else
        html << yield(page.number, page.first_item, page.last_item)
      end
        html << ' '
      end
         
    if always_show_anchors and not (wp_last = window_pages[-1]).last? 
      html << ' ... ' if last.number - wp_last.number > 1
      html << yield(last.number, last.first_item, last.last_item)
    end
         
    html
  end
  
  def controller_name
    controller.class.controller_name
  end

  def date_format(date)
    "#{Date::MONTHNAMES[date.mon]} #{date.day} #{date.hour}:#{date.min}"
  end

  def learn_more
    #this is quite possibly a very bad idea
    text = controller.send :render_to_string, :partial => 'learn'
    #spec says we want to break things up by sentence. 
    first, second, *rest = text.split(/\./).map { |s| s.chomp + "." }
    beginning = [first, second].join
    rest = rest.reject { |s| s == "." }.join
    rest.sub!(/\n\./, '') #trailing . is often around.
    beginning, rest = [beginning,rest].map { |p| BlueCloth.new(p).to_html }

    if rest && rest.size > 0
      stuff = <<EOT
   <p>%s</p>
		  <div id="learn_more" style="display: none;">
			<div>
              %s
			</div>
		  </div>
         <div class="btn-learn-more" id="learn-more-link">
			<a href="javascript:show_learn_more();" class="arrow">Learn more</a></div>

EOT
      stuff % [beginning, rest]
    else
      "<p>#{beginning}</p>"
    end
  end
  
  def contact_button(type = 'all')
    case type 
    when 'all'
      "/images/btn-contact-all-sponsors.gif"
    when 'senator'
      "/images/btn-contact-senator.gif"
    when 'representative'
      "/images/btn-contact-representative.gif"
    end
  end
  
  def opensecrets_button(person = nil)
    if person
      "<h3>See more campaign contribution data by visiting #{person.full_name}'s profile on <a class='arrow' target='_blank' href=\"http://www.opensecrets.org/politicians/summary.asp?cid=#{person.osid}\">OpenSecrets</a></h3>"
    else
      "<h3>See more at </h3><br /><a class='arrow' target='_blank' href=\"http://www.opensecrets.org\">OpenSecrets</a><br />"
    end
  end

  def maplight_link(bill = nil)
    if bill
      '<div class="maplight"><a href="http://maplight.org">Campaign contribution data for bills provided by <img src="/images/maplight-trans.png" alt="Maplight.org" /></a></div>'
    else
      '<h3>For more info about the campaign contributions behind the bills in Congress, visit <a class="arrow" target="_blank" href="http://maplight.org"><img class="noborder maplight" src="/images/maplight-trans.png" alt="Maplight.org" /></a>.</h3>'
    end
  end
  
  def govtrack_button
    '<div class="credit_button govtrack"><table cellspacing="0" cellpadding="0"><tr><td class="left" /><td class="center"><h3>Data made available by</h3> <a class="i" target="_blank" href="http://www.govtrack.us"><img src="/images/govtrack_button.gif" alt="Govtrack.US" /></a></td><td class="right" /></tr></table></div>'
  end

  def openhouse_button
    '<div class="credit_button openhouse"><table cellspacing="0" cellpadding="0"><tr><td class="left" /><td class="center"><h3>Help Open Congress</h3> <a class="i" target="_blank" href="http://www.theopenhouseproject.com/"><img src="/images/openhouse_button.gif" alt="The OpenHouse Project" /></a></td><td class="right" /></tr></table></div>'
  end
  
  def technorati_button
    '<a class="technorati" target="_blank" href="http://www.technorati.com">Information made available by <strong>Technorati</strong></a>'
  end

  def daylife_button
    '<a class="daily_life" target="_blank" href=\"http://www.daylife.com\">Information made available by <strong>Daily Life</strong></a>'
  end

  def short_date(date)
    date.strftime("%b %e")
  end
  
  def long_date(date)
    date.strftime("%B %e, %Y %I:%m %p")
  end

  def tiny_date(date)
    date.strftime("%b %e")
  end
  
  def number_to_ordinal(num)
    num = num.to_i
    if (10...20)===num
      "#{num}th"
    else
      g = %w{ th st nd rd th th th th th th }
      a = num.to_s
      c=a[-1..-1].to_i
      a + g[c]
    end
  end
  
  def pluralize_nn(count, singular, plural = nil)
        ((count == 1 || count == '1') ? singular : (plural || singular.pluralize))
  end
  
  def underscore_spaces(text)
    text.sub(/ /, '_')
  end
  
  def server_url_for(options = {})
    url_for options.update(:only_path => false)
  end
  
  def dropdown_trigger(text_name, trigger_text)
    "<span class=\"dropdown_trigger\"><a href=\"javascript:dropdown_open('#{text_name}_dropdown')\">#{trigger_text}</a></span>"
  end
  
  def dropdown_content(text_name)
    st = SiteText.find_dropdown_text(text_name)
    text = st ? st : ""
    
    "<div class=\"dropdown_content\" id=\"#{text_name}_dropdown\" style=\"display: none\"><div class=\"dropdown_close\"><a href=\"javascript:dropdown_close('#{text_name}_dropdown')\">close</a></div>#{text}</div>" 
  end
  
  def toggler(div_name, show_link_text, hide_link_text, show_link_class = "", hide_link_class = "")
    "<span class=\"\" id=\"show_#{div_name}\">" + link_to_function(show_link_text, "Element.show('hide_#{div_name}');Element.hide('show_#{div_name}');new Effect.BlindDown('#{div_name}');", :class => show_link_class) + "</span>" + 
    "<span class=\"\" id=\"hide_#{div_name}\" style=\"display:none;\">" + link_to_function(hide_link_text, "Element.show('show_#{div_name}');Element.hide('hide_#{div_name}');new Effect.BlindUp('#{div_name}');", :class => hide_link_class) + "</span>"
  end
  
	def toggler_with_span_class(div_name, show_link_text, hide_link_text, show_link_class = "", hide_link_class = "")
    "<span class=\"#{show_link_class}\" id=\"show_#{div_name}\"><a href=\"javascript:toggle('#{div_name}')\" class=\"#{show_link_class}\">#{show_link_text}</a></span>" +
    "<span class=\"#{hide_link_class}\" id=\"hide_#{div_name}\" style=\"display: none;\"><a href=\"javascript:toggle('#{div_name}')\" class=\"#{hide_link_class}\">#{hide_link_text}</a></span>" 
  end

  def ajax_toggler(div_name, show_link_text, hide_link_text, field_two, show_link_class = "", hide_link_class = "")
    "<span class=\"\" id=\"show_#{div_name}\">" + link_to_remote(show_link_text, {:update => div_name, :url => field_two, :complete => "Element.show('hide_#{div_name}');Element.hide('show_#{div_name}');new Effect.BlindDown('#{div_name}');"}, :class => show_link_class) + "</span>" + 
    " <span class='' id='hide_#{div_name}' style=\"display:none;\">" + link_to_function(hide_link_text, "Element.show('show_#{div_name}');Element.hide('hide_#{div_name}');new Effect.BlindUp('#{div_name}');", :class => hide_link_class) + "</span>"
  end
	
	def im_here(ctl,act)
		if request.path_parameters['controller'] == ctl
			if request.path_parameters['action'] == act
				"here"
			end
		end
	end
	def id_class
		"id=\"#{@admin_styles ? 'index' : controller.controller_name}\" class=\"#{params[:person_type]? params[:person_type] : controller.action_name}\""
	end
	def class_class
	  "class=\"#{controller.controller_name} #{params[:person_type]? params[:person_type] : controller.action_name}\""
	end
	
	def site_text_explain(tag)
    st = SiteText.find_explain(tag)
    text = st ? st : ""
    
    "<div class=\"explain_box\">#{text}</div>"
  end
  
  def site_text_plaintext(tag)
    st = SiteText.find_plaintext(tag)
    text = st ? st : ""
    
    text
  end
  
  # this is a temporary method to removed some weird data we are getting from govtrack
  def temp_url_strip(str)
    if ind = str.index(/&lt;a href/)
      return str[0..(ind-1)]
    else
      str
    end
  end
  
  # this method should be run on tag-stripped strings 
  def strip_unclosed_tag(str)
    if ind = str.index(/</)
      return str[0..(ind-1)]
    else
      str
    end
  end
  
  def admin_logged_in?
    return (logged_in? && current_user.user_role.can_blog) ? true : false
  end
  
  def can_blog?
    return (logged_in? && current_user.user_role.can_blog) ? true : false
  end
  
  def search_link(text)
    capitalized_words = []
    text.split.each { |w| capitalized_words << w.capitalize }
    "<a href=\"/search/result?q=#{text}&amp;search_congress%5B#{DEFAULT_CONGRESS}%5D=#{DEFAULT_CONGRESS}&amp;search_bills=1&amp;search_people=1&amp;search_committees=1&amp;search_industries=1&amp;search_issues=1&amp;search_commentary=1\" target=\"_top\">#{truncate(capitalized_words.join(' '), length => 70)}</a>"
  end

  def search_url(text)
    "/search/result?q=#{text}&amp;search_congress%5B#{DEFAULT_CONGRESS}%5D=#{DEFAULT_CONGRESS}&amp;search_bills=1&amp;search_people=1&amp;search_committees=1&amp;search_industries=1&amp;search_issues=1&amp;search_commentary=1"
  end
  
  ### XML/ATOM helpers
  def commentary_atom_entry(xml, commentary)
    xml.entry do
      xml.title   commentary.title
      xml.link    "rel" => "alternate", "href" => CGI.escapeHTML(commentary.url)
      xml.id      commentary.atom_id
      xml.updated commentary.date.strftime("%Y-%m-%dT%H:%M:%SZ")
      xml.author  { xml.name commentary.source } unless commentary.source.blank?
      xml.content(:type => 'html') do
        xml.text!(commentary.excerpt + "<br /><br />" + link_to("Go to article", commentary.url))
      end
    end
  end
  
  def bill_basic_atom_entry(xml, b, updated_method)
    xml.entry do
      xml.title   b.title_full_common
      xml.link    "rel" => "alternate", "href" => bill_url(b)
      xml.id      b.atom_id_as_entry
      
      if updated_method
        xml.updated b.stats.send(updated_method).strftime("%Y-%m-%dT%H:%M:%SZ")
      else
        xml.updated b.last_action.datetime.strftime("%Y-%m-%dT%H:%M:%SZ")
      end
      
      xml.content "type" => "html" do
        xml.text! b.title_official
      end
    end
  end
  
  def bill_action_atom_entry(xml, a)
    title_preface = ""
    case a.action_type
    when 'introduced'
      title_preface = 'Bill Introduced: '
    when 'topresident'
      title_preface = 'Bill Sent To President: '
    when 'signed'
      title_preface = 'Bill Signed by President: '
    when 'enacted'
      title_preface = 'Bill Enacted: '
    when 'vetoed'
      title_preface = 'Bill Vetoed: '
    end
    
    xml.entry do
      xml.title   title_preface + a.bill.title_full_common
      xml.link    "rel" => "alternate", "href" => bill_url(a.bill)
      xml.id      a.atom_id
      xml.updated a.datetime.strftime("%Y-%m-%dT%H:%M:%SZ")
      xml.content "type" => "html" do
        xml.text! a.bill.title_official + "<br /><br />"
        xml.text!(a.datetime.strftime("%B %d, %Y: ") + a.text) if a.text
      end
    end
  end

  
  def person_basic_atom_entry(xml, p, updated_method = :entered_top_viewed)
    xml.entry do
      xml.title   p.name
      xml.link    "rel" => "alternate", "href" => url_for(:only_path => false, :controller => 'people', :action => 'show', :id => p)
      xml.id      p.atom_id_as_entry
      xml.updated p.stats.send(updated_method).strftime("%Y-%m-%dT%H:%M:%SZ")
      xml.content "type" => "html" do
        xml.text! p.name
      end
    end
  end
  def add_friend_link_ajax(friend, update_div = "fdiv")
     if logged_in? 
       friend_login = CGI::escapeHTML(friend.login)
       f = current_user.friends.find_by_friend_id(friend.id)
       if f.nil? && friend != current_user
         link_to_remote("Add #{friend_login} to Friends", { :update => update_div, 
                             :url => {:controller => 'friends', 
                             :action => 'add', 
                             :login => current_user.login, 
                             :id => friend.id}})
       elsif f.nil? && friend == current_user
          ""
       elsif f.confirmed == true 
          "#{friend_login} is my friend"
       else
          "#{friend_login} has yet to approve me"
       end
     else
        link_to("Login", login_url) + " to add friends"
     end
  end

  def display_tree_recursive(tree, parent_id)
    ret = "\n<ul style=\"float:none;clear:both;\">"
    margin = 0
    tree.each do |node|
      if node.parent_id == parent_id
        ret += "\n\t<li style=\"margin-left:#{margin}px;\">"
        ret += yield node
        ret += display_tree_recursive(tree, node.id) { |n| yield n } unless node.children.empty?
        ret += "\t</li>\n"
      end
      margin = 20
    end
    ret += "</ul>\n"
  end
  

  def display_nested_set_rows(rows)
    ret = "<ul style=\"float:none;clear:both;\">"
    rows.each do |row|
      ret += "\n\t<li style=\"margin-left:#{row.level.to_i * 15}px;\">"
      ret += yield row
      ret += "\t</li>"
    end
    ret += "</ul>\n"
  end
  
  def percent_to_color(result) #where result is whole number percentage,
    color=[]
    if result.nil?
      color << "b2b2b2" 
    elsif result > 50
      color << ((100 - result) * 2.74).round.to_s(base=16)
      color << "ab"
      color << ((100 - result) * 2.86).round.to_s(base=16)
    elsif result < 50
      color << "c2"
      color << (result * 3.12).round.to_s(base=16)
      color << (result * 2.92).round.to_s(base=16)
    else
      color << "b2b2b2"
    end
    color_hex = []
    color.each do |c|
      if c.to_s.size < 2
        color_hex << "0#{c}"
      else
        color_hex << c
      end
    end
    color_out = "#" + color_hex.join
  return color_out
  end

  def integer_to_color(i)
    if i > 0
      "#5b9d39"
    elsif i < 0
      "#a61c1c"
    else
      "#b2b2b2"
    end
  end

	def draw_inline_user_bill_vote(bill)
    bill_vote_images = String.new
    bill_vote_images = inline_determine_support(bill)
    if logged_in?
      bv = current_user.bill_votes.find_by_bill_id(bill.id)
      if bv
        if bv.support == 0
          bill_vote_images = inline_determine_support(bill,0)
        else
          bill_vote_images = inline_determine_support(bill,1)
        end
      end
    end
    bill_vote_images = bill_vote_images
    return bill_vote_images
  end
  
	def inline_determine_support(bill, support = 10)
		yah = String.new
		nah = String.new
		if support == 0
			yah = "bill_support"
			nah = "bill_nosupport"
		elsif support == 1
			nah = "bill_support"
			yah = "bill_nosupport"
		else
			yah = "bill_nosupport"
			nah = yah
		end
		logger.info params[:controller]
		if request.path_parameters['controller'] == "battle_royale"
			if logged_in?
			"" +
			link_to_remote("Aye",
			{ :url => {:controller => 'battle_royale', :action => 'br_bill_vote', :bill => bill.ident, :id => 0}},
			:class => "aye #{yah}") +
			"" +

			link_to_remote("Nay",
			{:url => {:controller => 'battle_royale', :action => 'br_bill_vote', :bill => bill.ident, :id => 1}},
			:class => "nay #{nah}") +
			""
      else
        link_to("Aye", login_url(:modal => true, :login_action => 0),
  			:class => "modal_fire aye #{yah}") +
  			"" +

        link_to("Nay", login_url(:modal => true, :login_action => 1),
  			:class => "modal_fire nay #{nah}") +
  			""
       end
		else
		  if logged_in?
        "<div class='voting_buttons'>" +
          link_to_remote(image_tag('yes.png') + "<span>I Support this Bill</span>",
  			      {:url => {:controller => 'bill', :action => 'bill_vote', :bill => bill.ident, :id => 0}},
  			      :class => "yes #{yah}") +
        "
                                            
        " +
          link_to_remote(image_tag('no.png') + "<span>I Oppose this Bill</span>",
  			      {:url => {:controller => 'bill', :action => 'bill_vote', :bill => bill.ident, :id => 1}},
  			      :class => "no #{nah}") +
        "
        </div>
          <!-- <a href=\"\" class=\"more learn_trigger\"><span>I Want to Learn More</span></a> -->
          <a href=\"\" class=\"more learn_trigger\"><span></span></a>
        "
      else
        '<div class="voting_buttons">' +
          link_to(image_tag('yes.png') + "<span>I Support this Bill</span>",
              login_url(:modal => true, :login_action => 0), :class => "vote_trigger yes") + 
        "
          
        " +
          link_to(image_tag('no.png') + "<span>I Oppose this Bill</span>",
              login_url(:modal => true, :login_action => 1), :class => "vote_trigger no") +
        "
        </div>
          <!-- <a href=\"\" class=\"more learn_trigger\"><span>I Want to Learn More</span></a> -->
          <a href=\"\" class=\"more learn_trigger\"><span></span></a>
        "        
      end
		end
	end
  
  def user_bill_result(bill)
    vt = bill.bill_votes.count
    if vt == 0
      result = nil
    else
      bs = bill.bill_votes.count(:all, :conditions => "support = 0")
      bo = bill.bill_votes.count(:all, :conditions => "support = 1")      
      result = (bs.to_f / vt) * 100
      result = result.round
    end                    
    color = percent_to_color(result)
    "<div id=\"users_result\">
    <h3 class=\"clearfix\" style=\"color:#{color};\" id=\"support_#{bill.id.to_s}\">#{result.nil? ? "-" : result}%</h3>
    <h4>Users Support Bill</h4>
    <font>#{bs} in favor / #{bo} opposed</font>
    </div>"
  end
  
  def my_congresspeople_votes(bill)
    out = ""
    unless bill.roll_calls.empty?
      bill.roll_calls.each do |rc| 
        if current_user.my_sens 
          unless rc.action.nil?
            if rc.action.vote_type == 'vote' || rc.action.vote_type == 'vote2'
              if rc.action.where == 's'
                current_user.my_sens.each do |sen|
                  voted = rc.vote_for_person(sen).to_s 
                  out += "<p>#{sen.title_full_name}<font class='#{voted}'> #{voted} </font></p><font>[#{sen.party_and_state}]</font>"
                end
              end
            end
          end 
        end
        if current_user.my_reps
          unless rc.action.nil?
            if rc.action.vote_type == 'vote' || rc.action.vote_type == 'vote2'
              if rc.action.where == 'h'
                current_user.my_reps.each do |rep| 
                  voted = rc.vote_for_person(rep).to_s
                  out += "<p>#{rep.title_full_name}<font class='#{voted}'> #{voted} </font></p><font>[#{rep.party_and_state}]</font>"
                end
              end
            end
          end
        end 
      end   
      unless out.blank?
        return "<h5>My Regional Officials</h5>" + out
      end
    end             
  end
  
  def countdown_field(field_id, update_id, max, options = {})
    function = "$('#{update_id}').innerHTML = (#{max} - $F('#{field_id}').length);"
    count_field_tag(field_id,function,options)
  end

  def count_field(field_id, update_id, options = {})
    function = "$('#{update_id}').innerHTML = $F('#{field_id}').length;"
    count_field_tag(field_id,function,options)
  end

  def count_field_tag(field_id, function, options = {})  
    out = javascript_tag function
    out += observe_field(field_id, options.merge(:function => function))
    return out
  end
  
  def dbox_trigger(text_name)
    "<script type=\"text/javascript\">
    $j().ready(function() {
      $j('##{text_name}')
        .jqDrag('##{text_name}_drag')
        .jqResize('##{text_name}_resize')
        .jqm({
          trigger:'##{text_name}_trigger',
          overlay:0,                      
          onShow: function(h) {
            h.w.css('opacity',0.92).slideDown();
          },
          onHide: function(h) {
            h.w.slideUp('slow',function() {if(h.o) h.o.remove();})
          }
        })
        .jqmAddClose('##{text_name}_close');
    });
    </script>
    <a href=\"#\" id=\"#{text_name}_trigger\" class=\"dbox_trigger\">?</a>"
  end
  
  def dbox_content(text_name)
    st = SiteText.find_dropdown_text(text_name)
    text = st ? st : ""
    "<div id=\"#{text_name}\" class=\"jqmNotice\">
      <div class=\"jqmnTitle jqDrag\" id=\"#{text_name}_drag\">
      <span id=\"#{text_name}_close\" class=\"dbox_trigger close\">Close</span>
        <h1>What's this?</h1>
      </div>
     <div class=\"jqmnContent\">
     <p>#{text}</p>
     </div>
     <img src=\"/images/resize.gif\" id=\"#{text_name}_resize\" alt=\"resize\" class=\"dbox_resize\" />
     </div>"
  end
  
  def dbox_start(div_name, x_off, y_off, width, point = "")
    out = "<div class=\"dboxed\" id=\"#{div_name}\" style=\"display:none;\">
    <div style=\"position:relative;left:#{x_off.to_s ||= '80'}px;top:#{y_off.to_s ||= '30'}px;width:#{width.to_s}px;\">
    <table cellpadding=\"0\" cellspacing=\"0\" class=\"dbox\">
    <tr>
    <td class=\"tl #{point}\" />
    <td class=\"tc\" />
    <td class=\"tr #{point}\">"
    if point == ""
    out +=  link_to_function(image_tag('/images/close.png', :alt => 'Close', :id => "Close", :mouseover => '/images/close_hover.png'), "Element.hide('#{div_name}')")
    end
    out += '</td>
    </tr>
    <tr>
    <td class="cl" />
    <td class="cc">'
    return out
  end

  def dbox_end
    '</td>
    <td class="cr" />
    </tr>
    <tr>
    <td class="bl" />
    <td class="bc" />
    <td class="br" />
    </tr>
    </table>
    </div>
    </div>'
  end
  
  def make_tabs(tabs)
    make_tabs = tabs.inject([]) do |text, link|
      here = (link[1][:action] == controller.action_name) ? 'here' : ''
      text << "<li id='#{link[1][:action]}' class='#{here}'>" + link_to("<span>#{link[0].to_s}</span>", link[1], :class => link[0].slice!(0..3)) + "</li>"
     end
     make_tabs.join("\n")
  end

  def tag_cloud(tags, classes)
    max, min = 0, 0
    tags.each { |t|
      max = t[1] if t[1] > max
      min = t[1] if t[1] < min
    }

    divisor = ((max - min) / classes.size) + 1

    tags.each { |t|
      yield t[0], classes[(t[1] - min) / divisor]
    }
  end
  
  def bill_category(bill)
    klass = ''
    klass += bill.status_class
    unless bill.hot_bill_category.nil? 
      klass += ' hot'
    end
    if Time.at(bill.introduced) > 30.days.ago
      klass += ' new'
    end
    return klass
  end

  def meta_description_tag
    # site text always takes precedence over controller-set meta_description
    if @site_text_page && !@site_text_page.meta_description.blank?
      "<meta name=\"description\" content=\"#{@site_text_page.meta_description}\" />"
    elsif @meta_description
      "<meta name=\"description\" content=\"#{truncate(strip_tags(@meta_description), :length => 256)}\" />"
    else
      ""
    end
  end
  
  def meta_keywords_tag
    # site text always takes precedence over controller-set meta_keywords
    if @site_text_page && !@site_text_page.meta_keywords.blank?
      "<meta name=\"keywords\" content=\"#{@site_text_page.meta_keywords}\" />"
    elsif @meta_keywords
      "<meta name=\"keywords\" content=\"#{strip_tags(@meta_keywords)}\" />"
    else
      ""
    end
  end
  
  def page_title
    title = ""
    unless @site_text_page.nil? || @site_text_page.title_tags.blank?
      title += "#{@site_text_page.title_tags} - "
    end
    if @page_title
      title += @page_title
    end
    if @head_title
      title += ": #{@head_title}"
    end
    if @page_title_prefix
      title += " - #{@page_title_prefix}" 
    end
    stop = title.length > 113 ? (title.rindex(' ', 113)) : title.length
    title = title.length > 113 ? (title[0...stop] + "... ") : (title + " - ")
    title += "OpenCongress"                                   
    return title
  end 
  
  def info_box
    if @site_text_page && !@site_text_page.title_desc.blank?
      return "<div class=\"extra_description\">#{@site_text_page.title_desc}</div>"
    else
      return ""
    end
  end 
  
  def get_vote_image(vote)
    vote_hash = {
      "+" => image_tag("passed_big.png"),
  		"-" => image_tag("Failed_big.gif"),
  		"0" => "",
  		"P" => ""
    }
    
    vote_hash[vote]
  end

  def bookmarking_image
    "<link rel=\"image_src\" href=\"" + (@bookmarking_image.blank? ? "/images/fb-default.jpg" : @bookmarking_image) + "\" />"
  end
  
  def has_originating_chamber_roll_call?(bill)
    bill and bill.originating_chamber_vote and bill.originating_chamber_vote.roll_call
  end
end
