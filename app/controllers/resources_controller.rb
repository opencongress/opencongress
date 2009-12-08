class ResourcesController < ApplicationController
  before_filter :login_required, :only => "writerep"
  skip_before_filter :store_location, :except => [:index]

  def index
    @page_title = "OpenCongress Resources"
  end
  
  def syndicator
    @page_title = "Syndicator Widget"
  end
  
  def syndicator_panel
    num_items = params[:num_items].to_i || 5
    @bgcolor = params[:bg_color] || 'ffffff'
    @bordercolor = params[:bordercolor] || '999999'
    @textcolor = params[:textcolor] || '333333'
    @item_type = params[:item_type] || 'viewed-bill'

    @stat_type, object_type = @item_type.split(/-/)
    
    case @stat_type
    when 'topsearches'
      @items = Search.top_search_terms(num_items)
      @title = "Most Searched Terms on OpenCongress.org"
      @feed_link = ""
      @more_link = "/searches/popular"
      @more_text = "More Searches"
    when 'news', 'blog'
      display_commentary = (@stat_type == 'news') ? 'News' : 'Blogs'
      case object_type
      when 'sen'
        @items = Person.find_by_most_commentary(@stat_type, 'sen', num_items)
        @title = "Senators Most in #{display_commentary} on OpenCongress.org"
        @feed_link = "/people/senators/atom/most/#{@stat_type}"
        @more_link = "/people/senators/most/#{@stat_type}"
        @more_text = "More Senators"
      when 'rep'
        @items = Person.find_by_most_commentary(@stat_type, 'rep', num_items)
        @title = "Representatives Most in #{display_commentary} on OpenCongress.org"
        @feed_link = "/people/representatives/atom/most/#{@stat_type}"
        @more_link = "/people/representatives/most/#{@stat_type}"
        @more_text = "More Representatives"
      else
        @items = Bill.find_by_most_commentary(@stat_type, num_items)
        @title = "Bills Most in #{display_commentary} on OpenCongress.org"
        @feed_link = "/bill/atom/most/#{@stat_type}"
        @more_link = "/bill/most/#{@stat_type}"
        @more_text = "More Bills"
      end
    else
      case object_type
      when 'sen'
        @items = PageView.popular('Person', DEFAULT_COUNT_TIME, 540).select{|p| p.title == 'Sen.'}.slice(0, num_items)
        @title = "Most Viewed Senators on OpenCongress.org"
        @feed_link = "/people/atom_top20?type=sen"
        @more_link = "/people/senators?sort=popular"
        @more_text = "More Senators"
      when 'rep'
        @items = PageView.popular('Person', DEFAULT_COUNT_TIME, 540).select{|p| p.title == 'Rep.'}.slice(0, num_items)
        @title = "Most Viewed Representatives on OpenCongress.org"
        @feed_link = "/people/atom_top20?type=rep"
        @more_link = "/people/representatives?sort=popular"
        @more_text = "More Representatives"
      when 'committee'
        @items = PageView.popular('Committee', DEFAULT_COUNT_TIME, num_items)
        @title = "Most Viewed Committees on OpenCongress.org"
        @feed_link = "/committee/atom_top20"
        @more_link = "/committee/most_viewed"
        @more_text = "More Commmittees"
      when 'issue'
        @items = PageView.popular('Subject', DEFAULT_COUNT_TIME, num_items)
        @title = "Most Viewed Issues on OpenCongress.org"
        @feed_link = "/issue/atom_top20"
        @more_link = "/issue/most_viewed"
        @more_text = "More Issues"  
      else
        @items = PageView.popular('Bill', DEFAULT_COUNT_TIME, num_items)
        @title = "Most Viewed Bills on OpenCongress.org"
        @feed_link = "/bill/atom/most/viewed"
        @more_link = "/bill/most/viewed"
        @more_text = "More Bills"
      end
    end
    
    unless (/opencongress\.org/.match(request.referer)  or !request.referer)
      ref = PanelReferrer.find_or_create_by_referrer_url_and_panel_type(request.referer, 'SYNDICATOR')
      ref.views += 1
      ref.save
    end
    
    render :layout => false
  end
  
  def watching
    @page_title = "&quot;Congress, I'm Watching&quot; Widget"
  end
  
  def watching_panel
    @bgcolor = params[:bg_color] || 'ffffff'
    @bordercolor = params[:bordercolor] || '999999'
    @textcolor = params[:textcolor] || '333333'
    @item_type = params[:item_type] || 'viewed-bill'
    pass_bills_idents = params[:pass_bills].blank? ? [] : params[:pass_bills].split(/,/)
    dont_pass_bills_idents = params[:dont_pass_bills].blank? ? [] : params[:dont_pass_bills].split(/,/)
    
    @pass_bills = pass_bills_idents.collect { |i| Bill.find_by_ident(i) }
    @dont_pass_bills = dont_pass_bills_idents.collect { |i| Bill.find_by_ident(i) }
    
    @num_items = @pass_bills.size + @dont_pass_bills.size
    
    unless (/opencongress\.org/.match(request.referer)  or !request.referer)
      ref = PanelReferrer.find_or_create_by_referrer_url_and_panel_type(request.referer, 'IM_WATCHING')
      ref.views += 1
      ref.save
    end
    
    render :layout => false
  end
  
  def bill_number_search
    if params[:bill_status][:bill_number] and !params[:bill_status][:bill_number].empty?
      number = params[:bill_status][:bill_number].gsub(/[^0-9]/, '')
      
      unless number.blank?
        @bills = Bill.find(:all, 
                   :conditions => ["number = ? AND session = ?", number.to_i, DEFAULT_CONGRESS],
                   :limit => 5,
                   :order => 'lastaction DESC')
      end
    end
    partial = params[:bill_status][:partial].blank? ? 'bill_search_bill_status' : params[:bill_status][:partial]
    
    render :partial => partial, :layout => false
  end
  
  def bill_status
    if params[:bill_id] and !params[:bill_id].empty?
      @bill = Bill.find_by_ident(params[:bill_id])
    end
    
    @page_title = 'Bill Status Widget'
    @most_viewed_bills = PageView.popular('Bill', DEFAULT_COUNT_TIME, 10) || Bill.find(:all, :limit => 10)
  end
  
  def bill_status_panel
    @bgcolor = params[:bg_color] || 'ffffff'
    @bordercolor = params[:bordercolor] || '999999'
    @textcolor = params[:textcolor] || '333333'
    
    @bill = Bill.find_by_ident(params[:bill_id]) if params[:bill_id] and !params[:bill_id].empty?
    
    unless (/opencongress\.org/.match(request.referer) or !request.referer)
      ref = PanelReferrer.find_or_create_by_referrer_url_and_panel_type(request.referer, 'BILL_STATUS')
      ref.views += 1
      ref.save
    end
    
    render :layout => false
  end
  
  def issue_bills
    if params[:issue_id] and !params[:issue_id].empty?
      @issue = Subject.find_by_id(params[:issue_id])
    end
    @item_type = params[:item_type] || 'new-bill'
        
    @page_title = 'Bills by Issue Area Widget'
    @most_viewed_issues = PageView.popular('Subject', DEFAULT_COUNT_TIME, 10) || Issue.find(:all, :limit => 10)
  end
  
  def issue_bills_panel
    num_items = 5
    @bgcolor = params[:bg_color] || 'ffffff'
    @bordercolor = params[:bordercolor] || '999999'
    @textcolor = params[:textcolor] || '333333'
    @item_type = params[:item_type] || 'new-bill'
    issue_id = params[:issue_id] || 4166 # "Congress"  why not?

    @issue = Subject.find_by_id(issue_id)
    
    case @item_type
    when 'new-bill'
      @bills = @issue.newest_bills(num_items) 
      @title = "Newest Bills in #{@issue.term}"
      @feed_link = "/issue/atom/#{@issue.to_param}"
      @more_link = "/issue/show/#{@issue.to_param}"
    when 'viewed-bill'
      @bills = @issue.most_viewed_bills(num_items)
      @title = "Most Viewed Bills in #{@issue.term}"
      @feed_link = "/issue/atom/#{@issue.to_param}"
      @more_link = "/issue/show/#{@issue.to_param}"
    end
    
    @more_text = "More Bills"
    
    unless (/opencongress\.org/.match(request.referer) or !request.referer)
      ref = PanelReferrer.find_or_create_by_referrer_url_and_panel_type(request.referer, 'ISSUE_BILLS')
      ref.views += 1
      ref.save
    end
    
    render :layout => false
  end
  
  def issue_search
    if params[:issue_bills][:issue_text] and !params[:issue_bills][:issue_text].empty?
      query_stripped = params[:issue_bills][:issue_text].strip
      query_stripped = query_stripped.gsub(/\s+/," ")
      
      if (query_stripped.size > 0)
        @issues = Subject.full_text_search(query_stripped, :page => 1)
      end
    end
    
    render :layout => false
  end
  
  
  def congrelicious
  	@page_title = "Congrelicious"
  end
  
  def relinker
    @page_title = "Relink THOMAS Links"
    @warnings = ""
    
    unless params[:text].blank? 
      @text = String.new(params[:text])
      links = @text.scan(/(http\:\/\/thomas\.loc\.gov\/cgi-bin\/(?:bd)?query\/\w\?\w(\d+):([a-zA-Z.]+)(\d+)[^"\s]+)/)
    
      links.each do |l|
        logger.warn "INSPECT #{l.inspect}"
      
        bill = Bill.find_by_session_and_bill_type_and_number(l[1], Bill.long_type_to_short(l[2]), l[3])
        if bill
          @text.gsub!(l[0], url_for(:only_path => false, :controller => 'bill', :action => 'show', :id => bill.ident))
        else
          @warnings += "Could not find a corresponding bill for <b>#{l[0]}</b><br />"
        end
      end    
    end
  end
  
  def email_friend_form
    object_type = params[:object_class]
    id = params[:object_id]
    
    klass = Object.const_get object_type
    item = klass.find_by_id(id)
    render :partial => 'shared/email_friend_form', :locals => { :item => item }, :layout => false
  end

  def healthcare_panel
    @house_bill_ident = "111-h3962"
    @senate_bill_ident = "111-h3590"

    @house_bill = Bill.find_by_ident(@house_bill_ident)
    @senate_bill = Bill.find_by_ident(@senate_bill_ident)

    if params[:state] && @state_name = State.for_abbrev(params[:state])
      # Count number of users in this state tracking this bill
      @house_state_users = User.find_users_in_states_tracking([params[:state]], @house_bill, 1000).total
      @senate_state_users = User.find_users_in_states_tracking([params[:state]], @senate_bill, 1000).total
    end

    @page_title = "Healthcare Widget"

    render :layout => false
  end
  
  def email_friend_send
    @success = false
    if !simple_captcha_valid?
      @content = "The code you entered does not match the code in the image.  Please try again."
      render :layout => false
      return
    end
    object_type = params[:email][:object_type]
    id = params[:email][:object_id]
    
    klass = Object.const_get object_type
    item = klass.find_by_id(id)
    
    friend_email = FriendEmail.new
    friend_email.emailable = item
    friend_email.ip_address = request.remote_ip
    friend_email.save
    
    if object_type == 'Bill'
      subject = "OpenCongress: #{item.title_full_common}"
      url = "#{BASE_URL}bill/#{item.ident}/show"
      item_desc = "bill"
    elsif object_type == 'Person'
      subject = "OpenCongress: #{item.name}"
      url = "#{BASE_URL}person/show/#{item.to_param}"
      item_desc = "Member of Congress"
    elsif object_type == 'Subject'
      subject = "OpenCongress: #{item.term}"
      url = "#{BASE_URL}issue/show/#{item.to_param}"
      item_desc = "issue"
    elsif object_type == 'UpcomingBill'
      subject = "OpenCongress: #{item.title}"
      url = "#{BASE_URL}bill/upcoming/#{item.id}"
      item_desc = "bill"
    end
    
    dest_emails = params[:email][:dest_emails]
    dest_emails = dest_emails.split("\n")

    if params[:email]["cc_me"] == "1"
      dest_emails << params[:email][:email]
    end
    
    begin
      Emailer::deliver_friend(dest_emails, params[:email][:email], subject, url, item_desc, params[:email][:message])
      @content = "Your email has been delivered."
      @success = true
    rescue Exception => e
      @content = "There was an unknown error sending your email. Please try again later."
    end
      
    render :layout => false
  end
  
  def email_feedback_form
    @subject = params[:subject]
    render :layout => false
  end    
  
  def email_feedback
  #  debugger
    if !simple_captcha_valid?
      @content = "Captcha Failed.  Try again"
      render :layout => false
      return
    end
    
    cc = []
    if params[:feedback]["cc_me"] == "1"
      cc << params[:feedback][:email]
    end
    
    begin
      Emailer::deliver_feedback(cc, params[:feedback][:email], params[:feedback][:subject], params[:feedback][:message])
      @content = "Your feedback has been delivered."
    rescue Exception => e
      @content = "There was an unknown error sending your feedback. Please try again later."
    end
    render :layout => false
  end
  
  def district_from_address
    @district = ZipcodeDistrict.from_address(params[:address])
    
    if @district && @district.length == 1
      render :text => "<a href='#{BASE_URL}states/#{@district.first.state}/districts/#{@district.first.district}'>#{@district.first.state}-#{@district.first.district}</a> is your district."
    else
      render :text => "Your district could not be found."
    end
  end
  
  def write_rep_form
    @user = current_user
    @write_rep_email = WriteRepEmail.new
    
    @bill = Bill.find_by_id(params[:bill_id]) unless params[:bill_id].blank?
    
    unless @user.representative.nil?
      @representative = @user.representative
    else
      if logged_in? && @user.zipcode
        @sens, @reps = Person.find_current_congresspeople_by_zipcode(@user.zipcode, (@user.zip_four ? @user.zip_four : nil))
  	  
        if @reps.size == 1
    	    @representative = @reps.first
  	    
    	    @write_rep_email.person = @representative
    	  end
    	end
  	end
  	
  	unless @representative.nil?
  	  @write_rep_email.person = @representative
  	  @write_rep_email.state = @representative.state
  	  @write_rep_email.district = "#{@representative.state}-#{@representative.district}"
    end
    @write_rep_email.zip5 = @user.zipcode
    @write_rep_email.zip4 = @user.zip_four
    
    if @bill
      @write_rep_email.subject = "RE: #{@bill.title_full_common[0..250]}"
    end
    @write_rep_email.fname = @user.full_name
    @write_rep_email.email = @user.email
    
    render :layout => false
  end
  
  def write_rep_prepare
    @write_rep_email = WriteRepEmail.new(params[:write_rep_email])
    @write_rep_email.ip_address = request.remote_ip
    @success = @write_rep_email.save
    @error_msg = nil
    @captchas = {}
    if @success
      post_params = params[:write_rep_email].map { |k,v| "%s=%s" % [URI.encode(k.to_s), URI.encode(v.to_s)] }.join('&')
      
      #post_params = URI.encode(JSON.dump(params[:write_rep_email]))
      logger.warn "POST STRING: #{post_params}"
      begin
        http = Net::HTTP.new('dev.watchdog.net')
        http.start do |http|
          response = http.get("/api/wyr.prepare?#{post_params}")
          puts "HERE'S RESPONSE: #{response.body}"
          
          json = JSON.parse(response.body)
          puts json.inspect
          if json.has_key? "err_msg"
            @error_msg = json['err_msg']
            @success = false
            respond_to do |format|      
              format.js        
            end
            return
          else
            
            # now the response should be a hash of representatives; check for captchas
            json.keys.each do |name|
              captcha = json[name]['captcha_src']
              
              @captchas[name] = captcha unless captcha.nil?
            end
            
            if @captchas.empty?
              # send message now
              redirect_to :action => 'write_rep_send', :write_rep_email_id => @write_rep_email.id
              return
            else
              @captcha_form = true
              @write_rep_env = URI.encode(JSON.dump(json))
              respond_to do |format|      
                format.js        
              end
              return
            end
          end      
        end
      rescue TimeoutError
        # say something
        logger.warn "timeout"
      #rescue Exception => e
      #  logger.warn "Error with WYR prepare: #{e}"
      end
      
      logger.warn "Response body: #{response.body}"
    end
    
    respond_to do |format|      
      format.js        
    end
  end
  
  def write_rep_send
    logger.warn "GOT TO SEND: #{params[:write_rep_email_id]}"
    @error_msg = nil
    @wre = WriteRepEmail.find_by_id(params[:write_rep_email_id])
    if @wre
      captcha_values = params[:captcha_values]
      logger.warn captcha_values.inspect
      json = nil
      unless captcha_values.nil? or captcha_values.empty?
        json = JSON.parse(URI.decode(params[:write_rep_env]))
        captcha_values.keys.each do |cap|
          json[cap]['captcha_value'] = captcha_values[cap]
        end
        logger.warn "JSON DUMP: #{json.inspect}"
      end
      
      
      wrehash = @wre.attributes.dup
      wrehash.delete 'id'
      wrehash.delete 'created_at'
      wrehash.delete 'updated_at'
      wrehash.delete 'result'
      wrehash.delete 'ip_address'
      
      wrehash['env'] = JSON.dump(json) if json

      post_params = wrehash.map { |k,v| "%s=%s" % [CGI::escape(k.to_s), CGI::escape(v.to_s)] }.join('&')
      
      logger.warn "wrehash: #{post_params}"
      logger.warn "POST SEND STRING: #{post_params}"
      begin
        http = Net::HTTP.new('dev.watchdog.net')
        http.start do |http|
          response = http.post("/api/wyr.send", post_params)
          logger.warn "SEND BODY: #{response.body}"
          json = JSON.parse(response.body)
          logger.warn "SEND JSON INSPECT: #{json.inspect}"
          if json.has_key? "err_msg"
            @error_msg = json['err_msg']
            respond_to do |format|      
              format.js        
            end
            return
          end
              
          json.keys.each do |rep|
            person = Person.find_by_watchdog_id(rep)

            if person
              @wre.write_rep_email_msgids.create(:status => json[rep]['status'], :msgid => json[rep]['msgid'])
            else
              logger.warn "Couldn't find match for watchdog id: #{rep}"
            end
          end
        end
      end
    end
  end
end
