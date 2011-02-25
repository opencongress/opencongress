class Admin::StatsController < Admin::IndexController
  before_filter :can_stats
  def searches
    @searches = Search.top_search_terms
    @page_title = 'Top 100 Search Terms'
  end
  
  def referrers
    @top_referrers = PageView.find_by_sql("SELECT referrer, count(referrer) as count 
                                           FROM page_views
                                           WHERE REFERRER IS NOT NULL
                                           GROUP BY referrer
                                           ORDER BY count DESC
                                           LIMIT 20")
    @referred_bills = PageView.find_by_sql("SELECT viewable_id, COUNT(viewable_id) as count 
                                            FROM page_views 
                                            WHERE referrer IS NOT NULL AND
                                                  viewable_type='Bill'
                                            GROUP BY viewable_id ORDER BY count DESC LIMIT 20")
                                            
    @referred_people = PageView.find_by_sql("SELECT viewable_id, COUNT(viewable_id) as count 
                                            FROM page_views 
                                            WHERE referrer IS NOT NULL AND
                                                  viewable_type='Person'
                                            GROUP BY person_id ORDER BY count DESC LIMIT 20")
    @page_title = "Referrer Stats"
  end
  
  def panel
    @referrers = PanelReferrer.find(:all, :order => 'views DESC', :limit => 50)
    @page_title = "Syndication Panel Pages"
  end

  def userstats_data
    
    @user_graph = User.find(:all, :select => "count(id), date(created_at)", 
                            :group => "date(created_at)", 
                            :order => "date DESC", 
                            :limit => 30).reverse.collect {|p| [p.date,p.count]} 

    g = Graph.new
    g.title("Users over the last 30 days", '{font-size:26px;}')
    g.set_data(@user_graph.collect {|p| p[1]})
    g.set_x_labels(@user_graph.collect{|p| p[0]})
    g.set_y_max(500)
    g.set_y_label_steps(10)
    render :text => g.render
  end

  def bill_bookmarks_data
    @user_graph = Bookmark.find(:all, :select => "count(id), date(created_at)",
                            :conditions => "bookmarkable_type = 'Bill'", 
                            :group => "date(created_at)", 
                            :order => "date DESC", 
                            :limit => 30).reverse.collect {|p| [p.date,p.count]} 

    g = Graph.new
    g.title("Bill Bookmarks over the last 30 days", '{font-size:26px;}')
    g.set_data(@user_graph.collect {|p| p[1]})
    g.set_x_labels(@user_graph.collect{|p| p[0]})
    g.set_y_max(900)
    g.set_y_label_steps(10)
    render :text => g.render
  end

  def person_bookmarks_data
    @user_graph = Bookmark.find(:all, :select => "count(bookmarks.id), date(bookmarks.created_at) as date",
                            :joins => "INNER JOIN people ON people.id = bookmarkable_id",
                            :conditions => ["bookmarkable_type = 'Person' AND people.title = ?", params[:id].capitalize + "."], 
                            :group => "date(bookmarks.created_at)", 
                            :order => "date DESC", 
                            :limit => 30).reverse.collect {|p| [p.date,p.count]} 

    g = Graph.new
    g.title("#{CGI::escapeHTML(params[:id]).capitalize}'s tracked over the last 30 days", '{font-size:26px;}')
    g.set_data(@user_graph.collect {|p| p[1]})
    g.set_x_labels(@user_graph.collect{|p| p[0]})
    g.set_y_max(900)
    g.set_y_label_steps(10)
    render :text => g.render
  end

  def issue_bookmarks_data
    @user_graph = Bookmark.find(:all, :select => "count(id), date(created_at)",
                            :conditions => "bookmarkable_type = 'Subject'", 
                            :group => "date(created_at)", 
                            :order => "date DESC", 
                            :limit => 30).reverse.collect {|p| [p.date,p.count]} 

    g = Graph.new
    g.title("Issues tracked over the last 30 days", '{font-size:26px;}')
    g.set_data(@user_graph.collect {|p| p[1]})
    g.set_x_labels(@user_graph.collect{|p| p[0]})
    g.set_y_max(900)
    g.set_y_label_steps(10)
    render :text => g.render
  end

  def comments_data
    @user_graph = Comment.find(:all, :select => "count(id), date(created_at)",
                            :group => "date(created_at)", 
                            :order => "date DESC", 
                            :limit => 30).reverse.collect {|p| [p.date,p.count]} 

    g = Graph.new
    g.title("Comments over the last 30 days", '{font-size:26px;}')
    g.set_data(@user_graph.collect {|p| p[1]})
    g.set_x_labels(@user_graph.collect{|p| p[0]})
    g.set_y_max(120)
    g.set_y_label_steps(10)
    render :text => g.render
  end

  def comment_ratings_data
    @user_graph = CommentScore.find(:all, :select => "count(id), date(created_at)",
                            :group => "date(created_at)", 
                            :order => "date DESC", 
                            :limit => 30).reverse.collect {|p| [p.date,p.count]} 

    g = Graph.new
    g.title("Comment Ratings over the last 30 days", '{font-size:26px;}')
    g.set_data(@user_graph.collect {|p| p[1]})
    g.set_x_labels(@user_graph.collect{|p| p[0]})
    g.set_y_max(120)
    g.set_y_label_steps(10)
    render :text => g.render
  end

  def news_ratings_data
    @user_graph = CommentaryRating.calculate(:count, :id, :include => "commentary",
                                             :conditions => ["commentaries.is_news = ?", true],
                                             :group => "date(commentary_ratings.created_at)",
                                             :order => "date(commentary_ratings.created_at) ASC",
                                             :limit => 30)

    g = Graph.new
    g.title("News Ratings over the last 30 days", '{font-size:26px;}')
    g.set_data(@user_graph.collect {|p| p[1]})
    g.set_x_labels(@user_graph.collect{|p| p[0]})
    g.set_y_max(120)
    g.set_y_label_steps(10)
    render :text => g.render
  end

  def blog_ratings_data
    @user_graph = CommentaryRating.calculate(:count, :id, :include => "commentary",
                                             :conditions => ["commentaries.is_news = ?", false],
                                             :group => "date(commentary_ratings.created_at)",
                                             :order => "date(commentary_ratings.created_at) ASC",
                                             :limit => 30)

    g = Graph.new
    g.title("Blog Ratings over the last 30 days", '{font-size:26px;}')
    g.set_data(@user_graph.collect {|p| p[1]})
    g.set_x_labels(@user_graph.collect{|p| p[0]})
    g.set_y_max(120)
    g.set_y_label_steps(10)
    render :text => g.render
  end


  def confirmed_friendships_data
    @user_graph = Friend.find(:all, :select => "count(id), date(confirmed_at)",
                            :conditions => ["confirmed_at is not null"],
                            :group => "date(confirmed_at)", 
                            :order => "date DESC", 
                            :limit => 30).reverse.collect {|p| [p.date,p.count]} 

    g = Graph.new
    g.title("Confirmed Friendships over the last 30 days", '{font-size:26px;}')
    g.set_data(@user_graph.collect {|p| p[1]})
    g.set_x_labels(@user_graph.collect{|p| p[0]})
    g.set_y_max(120)
    g.set_y_label_steps(10)
    render :text => g.render
  end

  def unconfirmed_friendships_data
    @user_graph = Friend.find(:all, :select => "count(id), date(created_at)",
                            :conditions => ["confirmed_at is null"],
                            :group => "date(created_at)", 
                            :order => "date DESC", 
                            :limit => 30).reverse.collect {|p| [p.date,p.count]} 

    g = Graph.new
    g.title("Un-confirmed Friendships over the last 30 days", '{font-size:26px;}')
    g.set_data(@user_graph.collect {|p| p[1]})
    g.set_x_labels(@user_graph.collect{|p| p[0]})
    g.set_y_max(120)
    g.set_y_label_steps(10)
    render :text => g.render
  end

  def billvotes_data
    @user_graph = BillVote.find(:all, :select => "count(id), date(created_at)",
                            :group => "date(created_at)", 
                            :order => "date DESC",
                            :conditions => ["support = ?", params[:id]], 
                            :limit => 30).reverse.collect {|p| [p.date,p.count]} 

    g = Graph.new
    g.title("#{params[:id] == "0" ? "Nay" : "Aye" } Bill Votes over the last 30 days", '{font-size:26px;}')
    g.set_data(@user_graph.collect {|p| p[1]})
    g.set_x_labels(@user_graph.collect{|p| p[0]})
    g.set_y_max(300)
    g.set_y_label_steps(10)
    render :text => g.render
  end
  
  def users
    @total_users = User.count
    @total_bookmarks = Bookmark.count
    @total_billvotes = BillVote.count
    @total_papproval = PersonApproval.count
    @total_comments = Comment.count
    @total_friendships = Friend.count / 2
    
    @inactive_users = User.count(:conditions => ["users.previous_login_date < ? OR users.previous_login_date IS NULL", 3.months.ago])
    @active_users = User.count(:conditions => ["users.previous_login_date > ?", 1.months.ago])
    
    @state_users = User.find_by_sql("SELECT state_cache, count(*) as cnt FROM users GROUP BY state_cache ORDER BY state_cache")
    all_district_users = User.find_by_sql("SELECT district_cache, count(*) as cnt FROM users GROUP BY district_cache ORDER BY district_cache")
    @multiple_dist = 0
    @district_users = []
    all_district_users.each do |du|
      if du.district_cache.size > 1
        @multiple_dist += du.cnt.to_i
      else
        @district_users << du
      end
    end
    @district_users.sort! { |a,b|
      if a.district_cache.first.nil?
        1
      elsif b.district_cache.first.nil?
        -1
      else
        a_state, a_dist = a.district_cache.first.split(/-/)
        b_state, b_dist = b.district_cache.first.split(/-/)
    
        if a_dist.nil?
          1
        elsif b_dist.nil?
          -1
        elsif a_state == b_state
          a_dist.to_i <=> b_dist.to_i
        else
          a_state <=> b_state
        end
      end
    }
      
    # @users = open_flash_chart_object(700,250, '/admin/stats/userstats_data', false, '/')
    # @bill_bookmarks = open_flash_chart_object(700,250, '/admin/stats/bill_bookmarks_data', false, '/')
    # @rep_bookmarks = open_flash_chart_object(700,250, '/admin/stats/person_bookmarks_data/rep', false, '/')
    # @sen_bookmarks = open_flash_chart_object(700,250, '/admin/stats/person_bookmarks_data/sen', false, '/')
    # @issue_bookmarks = open_flash_chart_object(700,250, '/admin/stats/issue_bookmarks_data', false, '/')
    # @teh_comments = open_flash_chart_object(700,250, '/admin/stats/comments_data', false, '/')
    # @bill_votes_aye = open_flash_chart_object(700,250, '/admin/stats/billvotes_data/1', false, '/')
    # @bill_votes_nay = open_flash_chart_object(700,250, '/admin/stats/billvotes_data/0', false, '/')
    # @confirmed_friendships = open_flash_chart_object(700,250, '/admin/stats/confirmed_friendships_data', false, '/')
    # @unconfirmed_friendships = open_flash_chart_object(700,250, '/admin/stats/unconfirmed_friendships_data', false, '/')
    # @comment_ratings_data = open_flash_chart_object(700,250, '/admin/stats/comment_ratings_data', false, '/')
    # @news_ratings_data = open_flash_chart_object(700,250, '/admin/stats/news_ratings_data', false, '/')
    # @blog_ratings_data = open_flash_chart_object(700,250, '/admin/stats/blog_ratings_data', false, '/')

    
  end
  
  def bills
    @page_title = "Bill Stats"
    @session = params[:session].blank? ? Settings.default_congress : params[:session]
    if params[:format] == 'csv'
      @bills = Bill.find(:all, :conditions => ["session = ?", @session], 
                        :order => 'bills.page_views_count DESC')
    else
      @bills = Bill.find(:all, :conditions => ["session = ?", @session], 
                        :order => 'bills.page_views_count DESC').paginate(:page => params[:page])
    end
    
    @total_pageviews = Bill.sum('page_views_count', :conditions => ['session = ?', @session])
    @total_bookmarks = Bookmark.count_by_sql(["SELECT count(*) FROM bookmarks INNER JOIN bills ON bills.id=bookmarks.bookmarkable_id 
                                               WHERE bills.session=? AND bookmarks.bookmarkable_type='Bill'", @session])
    @total_comments = Comment.count_by_sql(["SELECT count(*) FROM comments INNER JOIN bills ON bills.id=comments.commentable_id 
                                             WHERE bills.session=? AND comments.commentable_type='Bill'", @session])
    @total_ayes = BillVote.count_by_sql(["SELECT count(*) FROM bill_votes INNER JOIN bills ON bills.id=bill_votes.bill_id 
                                          WHERE bills.session=? AND bill_votes.support='0'", @session])                                          
    @total_nays = BillVote.count_by_sql(["SELECT count(*) FROM bill_votes INNER JOIN bills ON bills.id=bill_votes.bill_id 
                                          WHERE bills.session=? AND bill_votes.support='1'", @session])
                                          
    respond_to do |format|
      format.html
      format.csv { render :layout => false }
    end                                      
  end
  
  def partner_email
    @page_title = "Partner Email Signups"
    if params[:format] == 'csv'
      @users = User.find(:all, :conditions => ["partner_mailing = ?", true], 
                        :order => 'created_at DESC')
    else
      @users = User.find(:all, :conditions => ["partner_mailing = ?", true], 
                        :order => 'created_at DESC').paginate(:page => params[:page])
    end
                                              
    respond_to do |format|
      format.html
      format.csv { render :layout => false }
    end                                      
  end
  
  def mypn
    @users = PoliticalNotebook.find_by_sql(["SELECT count(political_notebooks.user_id) FROM political_notebooks 
                              INNER JOIN notebook_items ON political_notebooks.id=notebook_items.political_notebook_id 
                              GROUP BY political_notebooks.user_id 
                              ORDER BY political_notebooks.user_id;", 1.month.ago])

    @active_users = PoliticalNotebook.find_by_sql(["SELECT count(political_notebooks.user_id) FROM political_notebooks 
                              INNER JOIN notebook_items ON political_notebooks.id=notebook_items.political_notebook_id 
                              WHERE notebook_items.created_at > ? GROUP BY political_notebooks.user_id 
                              ORDER BY political_notebooks.user_id;", 1.month.ago])
                              
    @item_types = NotebookItem.find_by_sql("SELECT type, count(*) AS cnt FROM notebook_items GROUP BY type;")
  end
  
  def data
    @newest_person_news = Commentary.find(:first, :conditions => "is_ok='t' AND is_news='t' AND commentariable_type = 'Person'", 
                                          :order => "date DESC")
    @newest_person_blog = Commentary.find(:first, :conditions => "is_ok='t' AND is_news='f' AND commentariable_type = 'Person'", 
                                          :order => "date DESC")
    @newest_bill_news = Commentary.find(:first, :conditions => "is_ok='t' AND is_news='t' AND commentariable_type = 'Bill'", 
                                          :order => "date DESC")
    @newest_bill_blog = Commentary.find(:first, :conditions => "is_ok='t' AND is_news='f' AND commentariable_type = 'Bill'", 
                                          :order => "date DESC")
    @newest_action = Action.find(:first, :include => :bill, :conditions => 'bills.number IS NOT NULL', :order => 'actions.date DESC')
 
    @latest_roll_call_date_govtrack = RollCall.latest_roll_call_date_on_govtrack
    @latest_roll_call_oc = RollCall.find(:first, :order => 'date DESC')
    
    @latest_bill_text = BillTextVersion.find(:first, :conditions => 'file_timestamp IS NOT NULL', :order => 'file_timestamp DESC')
  
    @page_title = "OpenCongress Data Status"
  end
end
