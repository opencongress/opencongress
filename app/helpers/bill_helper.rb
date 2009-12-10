module BillHelper

  def bill_type_name(bill_type)
    case bill_type
    when 'hr'  : '<div>Resolutions</div> <span>House of Representatives</span>'
    when 'h' : '<div>Bills</div> <span>House of Representatives</span>'
    when 'hj' : '<div>Joint Resolutions</div> <span>House of Representatives</span>'
    when 'hc' : '<div>Concurrent Resolution</div> <span>House of Representatives</span>'
    when 's'  : '<div>Bills</div> <span>Senate</span>'
    when 'sr'  : '<div>Resolutions</div> <span>Senate</span>'
    when 'sj'  : '<div>Joint Resolutions</div> <span>Senate</span>'
    when 'sc'  : '<div>Concurrent Resolution</div> <span>Senate</span>'
    end
  end
  
  def bill_type_page_title(bill_type)
    case bill_type
    when 'hr'  : 'Resolutions: House of Representatives'
    when 'h' : 'Bills: House of Representatives'
    when 'hj' : 'Joint Resolutions: House of Representatives'
    when 'hc' : 'Concurrent Resolution: House of Representatives'
    when 's'  : 'Bills: Senate'
    when 'sr'  : 'Resolutions: Senate'
    when 'sj'  : 'Joint Resolutions: Senate'
    when 'sc'  : 'Concurrent Resolution: Senate'
    end
  end

  def bill_name(bill_type, number)
    case bill_type
    when 'hr'  : 'H.Res.'
    when 'h' : 'H.R.'
    when 'hj' : 'H.J.Res.'
    when 'hc' : 'H.Con.Res.'
    when 's'  : 'S.'
    when 'sr'  : 'S.Res.'
    when 'sj'  : 'S.J.Res.'
    when 'sc'  : 'S.Con.Res.'
    end + number.to_s
  end

  def title
    "#{@bill.title_typenumber_only}: #{@bill.title_official}"
  end

  def em_title
    "#{@bill.title_typenumber_only}: <em>#{@bill.title_official}</em>"
  end

  def official_title
    @bill.title_official.blank? ? "#{@bill.title_typenumber_only}" : "#{@bill.title_official}"
  end

  def bill_titles_html
    @bill.bill_titles.map do |bt|

      "<li><em>#{bt.title_type.capitalize}:</em> " +
      " #{bt.title}" + (bt.as != '' ? "<em> as #{bt.as}.</em>" : ".") + "</li>"
    end
  end

  def display_bill_titles
    "<a href='#' id='bill_title_link' onclick='change_vis_text(\"bill_titles\", " +
      "\"bill_title_link\", \"...all bill titles\", \"...hide bill titles\");return false'>" +
      "...all bill titles</a>"
  end

  def bill_related_bills_html
    return '' unless @bill.related_bills.size > 0
    render :partial => 'related_bills_list', :object => @bill.related_bills
  end

  def display_related_bills
    return "No related bills" unless @bill.related_bills.size > 0
    "<a href='#' id='bill_related_link' onclick='change_vis_text(\"bill_related_bills\", " +
      "\"bill_related_link\", \"Show related bills\", \"Hide related bills\");return false'>" +
      "Show related bills</a>"
  end

	def bill_related_list 
		bill_limit = 6
		text = partial_list(@bill.related_bills, :title_full_common, bill_limit,
		"#{@bill.related_bills.size - bill_limit} more", "bill_related_extra",
		"bill_related_more", "show", "bill", true, 75)
	end
	
  def bill_subject_list
    # item_limit is the initial number of items to show
    item_limit = 4
    text = partial_list(@bill.subjects, :term, item_limit,
      "#{@bill.subjects.size - item_limit} more", "bill_subjects_extra",
      "bill_subjects_more", "show", "issue", true, false)
    # Show nothing if the list is empty
    text == "" ? '' : "#{text}"
  end

  def bill_summary_with_more
    summary_no_html = @bill.summary.gsub(/<\/?[^>]*>/, "")
    summary_no_html.gsub!(/"/, "\\\"")
    summary_no_html.gsub!(/'/, "&apos;")

    summary = @bill.summary
    summary.gsub!(/THOMAS\sHome[\w\s\|]*/,"")
		summary.gsub!(/(\(\d+\))/) { |d| '<br /><strong>' + $1 + '</strong>'}
		summary.gsub!(/(\(Sec\.\s\d+\))/) { |s| '<br /><br /><h4>' + $1 + '</h4>'}
    if summary
      if summary.length <= 300
        out = summary
      else
        summary.gsub!(/"/, "\\\"")
        summary.gsub!(/'/, "&apos;")
      
        out = "<script type='text/javascript'>
        $j().ready(function() {
        	$j('#bill_summary_extra').jqm({trigger: 'a.summary_trigger'});
        });
        </script>"
        
        out += summary_no_html[0..290] + "<span id=\"bill_summary_extra\" class='jqmWindow scrolling'><div class=\"ie\"><a href=\"#\" class=\"jqmClose\">Close</a></div><h3>Official Summary</h3>#{summary}<br /><br /></span>...<a href='#' class='summary_trigger more'><strong>Read the Rest</strong></a>"
      end
    end
  end

  def co_sponsor_list
   	text = "<ul>"
		@bill.co_sponsors[0..@bill.co_sponsors.size].each do |c|
		  text += "<li>"
		  text += link_to c.name, :controller => 'people', :action => 'show', :id => c.id
		  text += "</li>"
		end
    text += "</ul>"
		return text
  end
	
	def committee_list(start,stop)
		text = "<ul class='button'>"
		@bill.committees[start..stop].each do |c|
		  text += "<li>"
		  text += link_to c.proper_name, :controller => 'committee', :action => 'show', :id => c.id
		  text += "</li>"
		end
    text += "</ul>"
		return text
	end
    
  def bill_full_text_link
    #"http://thomas.loc.gov/cgi-bin/query/z?c#{@bill.session}:#{@bill.title_typenumber_only}:"
    url_for :controller => 'bill', :action => 'text', :id => @bill.ident
  end

  def bill_active
    '<div class="bill_active">Active</div>' if @bill.last_action.datetime > Time.now.last_month
  end

  def limited_summary
    if @bill.summary.length < 300
      "#{@bill.summary}"
    else
      "#{@bill.summary.slice(0..299)} ... <a "
    end
  end
  
  def action
    "Latest action: <span class='bill_action'>#{@bill.action}</span>."
  end
  
  def sponsor
    "Sponsored by <span class='person_name'>#{@bill.sponsor.name}</span>."
  end
  
  
	def bill_status_table(bill = @bill)
		status_hash = bill.bill_status_hash
		text = "<table border='0' cellpadding='0' cellspacing='0' id='bill-status'>"
		text += "<tr>"
    pending = false
		status_hash['steps'].each do |s|
    current = ''
      if s.has_value?('Bill Becomes Law') || s.has_value?('Bill Is Law') || s.has_value?('Resolution Passed')
        text += "<td class='divide #{s['class']}'><span>&nbsp;</span></td>"
        text += "<td id='bill-law' class='#{s['class']}'></td>"
      else
        if pending == false
          if s['result'] == 'Pending'
            pending = true
            current = ' current'
          end
        end
        text += "<td class='divide #{s['class']}#{current}'><span>&nbsp;</span></td><td class='#{s['class']}'>"
        unless s['roll_id'].blank?
          text += "<a href=/roll_call/show/#{s['roll_id']}>"
        end  
        text += "<table class='info' cellpadding='0' cellspacing='0'><tr><td>#{s['text'].gsub(/\s/, "<br/>")}</td></tr>"
        text += "</table>"
        unless s['roll_id'].blank?
          text += "</a>"
        end
        text += "</td>"
			  if s.has_value?('Failed')
			    text += "<td class='close'></td>"
			  end
  		end
  	end
    text += "</tr></table><br />\n"
    
		text += "<table border='0' cellpadding='0' cellspacing='0' id='bill-status-dates'>"
		text += "<tr>"
    pending = false
		status_hash['steps'].each do |s|
    current = ''
      if s.has_value?('Bill Becomes Law') || s.has_value?('Bill Is Law') || s.has_value?('Resolution Passed')
        text += "<td class='divide #{s['class']}'><span>&nbsp;</span></td>"
      else
        if pending == false
          if s['result'] == 'Pending'
            pending = true
            current = ' current'
          end
        end
        text += "<td class='divide #{s['class']}#{current}'><span class=\"hump\">&nbsp;</span></td><td class='#{s['class']}'>"
        text += "<table class='info' cellpadding='0' cellspacing='0'><tr><td><strong>#{s['date'] ? s['date'].strftime('%m/%d/%y') : "<span class='empty'>&nbsp;</span>"}</strong></td></tr>"
        text += "</table>"
        text += "</td>"
			  if s.has_value?('Failed')
			    text += "<td class='close'></td>"
			  end
  		end
  	end
    text += "</tr></table><br />\n"
    
    return text
  end

	def other_bills_tracking
		out = ""
		num = @tracking_suggestions.length
		limit = 5
		@tracking_suggestions[0..4].each do |t|
			out += "<table cellspacing='0' cellpadding='0'>"
			out += "\n<tr><td style='padding-right:5px;'>"
			out += link_to((truncate t[:bill].title_full_common, :length => 30), {:controller => 'bill', :action => 'show', :id => t[:bill].ident}) + "</td>\n"
			out += "<td>[" +  link_to(t[:trackers], {:controller => 'friends', :action => 'tracking_bill', :id => t[:bill].ident}) + "]</td></tr>\n"
			out += "</table>"
		end
		more = num - limit
		if more > 0
			out += "<table id='more_tracking_suggestions' cellspacing='0' cellpadding='0' style='display:none;'>\n"
			@tracking_suggestions[5..num].each do |t|
					out += "\n<tr><td style='padding-right:5px;'>"
					out += link_to((truncate t[:bill].title_full_common, :length => 30), {:controller => 'bill', :action => 'show', :id => t[:bill].ident}) + "</td>\n"
					out += "<td>[" +  link_to(t[:trackers], {:controller => 'friends', :action => 'tracking_bill', :id => t[:bill].ident}) + "]</td></tr>\n"
			end
			out += "</table>\n"
			out += toggler("more_tracking_suggestions", "#{more} more bills", "Hide Others Tracking", "arrow", "arrow-hide")
		end
	return out
	end

end
