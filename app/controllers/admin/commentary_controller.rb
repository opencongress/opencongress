class Admin::CommentaryController < Admin::IndexController    
  before_filter :can_moderate, :only => ["pending", "update_pending"]
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    # this action is too costly, redirect
    redirect_to :controller => 'admin/index'

    #@commentary_pages, @commentaries = paginate :commentaries, :per_page => 10
  end

  def pending
    @commentaries = Commentary.find_all_by_status('PENDING', :limit => 10)
    @total_commentaries = Commentary.count_by_sql("SELECT count(*) FROM commentaries WHERE status='PENDING'")
    
    @page_title = "Pending News and Blog Articles"
  end
  
  def clear_cache
    Rails.cache.clear

    flash[:notice] = "memcache cleared."
    
    redirect_to :controller => "/admin/index"
  end
  
  def update_pending
    statuses = params[:commentary]
    
    if statuses
      statuses.keys.each do |k|
        c = Commentary.find_by_id(k)
        
        if c
          c.status = statuses[k]
          c.is_ok = 'true' if statuses[k] == 'OK'
          c.save
          
          c.commentariable.increment!(c.is_news ? :news_article_count : :blog_article_count)
          
        end
      end
      
      flash[:notice] = "Commentaries have been updated"
    end

    redirect_to :action => 'pending'
  end
  
  def add
    @people = (Person.representatives << Person.senators).flatten
    @page_title = "Add a News/Blog Article"
  end
  
  def show
    @commentary = Commentary.find(params[:id])
  end

  def new
    @commentary = Commentary.new
    
    if params[:commentariable_type].blank? && params[:commentariable_id].blank?
      redirect_to :action => 'add'     
    else
      klass = Object.const_get params[:commentariable_type]
      @commentary.commentariable = klass.find_by_id(params[:commentariable_id])
    end
  end

  def create
    @commentary = Commentary.new(params[:commentary])
    @commentary.status = 'OK'
    @commentary.is_ok = true

    if @commentary.save
      flash[:notice] = 'Commentary was successfully created.'
      @commentary.commentariable.expire_commentary_fragments(@commentary.is_news? ? 'news' : 'blog')
      
      @commentary.commentariable.increment!(@commentary.is_news ? :news_article_count : :blog_article_count)
      
      case @commentary.commentariable_type
      when 'Bill', 'Person'
        redirect_to polymorphic_url([@commentary.commentariable])
      when 'UpcomingBill'
        redirect_to :controller => 'bill', :action => 'upcoming', :id => @commentary.commentariable
      else
        render :action => 'list'
      end
    else
      render :action => 'new'
    end
  end

  def edit
    @commentary = Commentary.find(params[:id])
  end

  def update
    @commentary = Commentary.find(params[:id])
    
    if @commentary.update_attributes(params[:commentary])
      flash[:notice] = 'Commentary was successfully updated.'
      case @commentary.commentariable_type
      when 'Bill', 'Person'
        redirect_to polymorphic_url([@commentary.commentariable])
      when 'UpcomingBill'
        redirect_to :controller => 'bill', :action => 'upcoming', :id => @commentary.commentariable
      else
        render :action => 'list'
      end
    else
      render :action => 'edit'
    end
  end

  def mass_delete
    @commentary_ids = params[:mass_delete_ids]
    
    c = nil
    object = nil
    @commentary_ids.each do |c_id|
      c = Commentary.find_by_id(c_id)
      if c
        bc = BadCommentary.new(:url => c.url, :commentariable_id => c.commentariable_id, :commentariable_type => c.commentariable_type, :date => c.date)
        bc.save
        c.destroy
        c.commentariable.decrement!(c.is_news ? :news_article_count : :blog_article_count)
        object = c.commentariable unless object
        #logger.info "%%%%%%%%%%%%%%%%%%% #{c_id}"
      end
    end

    object.expire_commentary_fragments(c.is_news? ? 'news' : 'blog')

    redirect_to case c.commentariable_type
    when 'Bill', 'Person'
      polymorphic_url([c.commentariable], :action => (c.is_news? ? 'news' : 'blogs'))
    when 'UpcomingBill'
      { :controller => 'bill', :action => 'upcoming', :id => c.commentariable }
    end
  end
  
  def destroy
    @commentary = Commentary.find(params[:id])
    bc = BadCommentary.new(:url => @commentary.url, :commentariable_id => @commentary.commentariable_id, :commentariable_type => @commentary.commentariable_type, :date => @commentary.date)
    bc.save
    @commentary.destroy
    @commentary.commentariable.decrement!(@commentary.is_news ? :news_article_count : :blog_article_count)
    flash[:notice] = 'Commentary was deleted.'    
    redirect_to case @commentary.commentariable_type
    when 'Bill', 'Person'
      polymorphic_url([@commentary.commentariable])
    when 'UpcomingBill'
      { :controller => 'bill', :action => 'upcoming', :id => @commentary.commentariable }
    end

  end
  
  def person_cleanup
    @person = Person.find_by_id(params[:person_id])

    deleted = @person.cleanup_commentaries
    
    flash[:notice] = "Commentaries cleaned up. #{deleted} articles deleted."
    
    redirect_to :controller => '/people', :action => 'show', :id => @person
  end
  
end
