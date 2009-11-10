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
    ActionController::Base.cache_store.clear
    
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
      when 'Bill'
        redirect_to :controller => '/bill', :action => 'show', :id => @commentary.commentariable.ident
      when 'Person'
        redirect_to :controller => '/people', :action => 'show', :id => @commentary.commentariable
      when 'UpcomingBill'
        redirect_to :controller => '/bill', :action => 'upcoming', :id => @commentary.commentariable
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
      when 'Bill'
        redirect_to :controller => '/bill', :action => 'show', :id => @commentary.commentariable.ident
      when 'Person'
        redirect_to :controller => '/people', :action => 'show', :id => @commentary.commentariable
      when 'UpcomingBill'
        redirect_to :controller => '/bill', :action => 'upcoming', :id => @commentary.commentariable
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
        c.status = 'DELETED'
        c.is_ok = false
        c.save
        
        c.commentariable.decrement!(c.is_news ? :news_article_count : :blog_article_count)
        
        object = c.commentariable unless object
        logger.info "%%%%%%%%%%%%%%%%%%% #{c_id}"
      end
    end
    
    object.expire_commentary_fragments(c.is_news? ? 'news' : 'blog')
    
    case c.commentariable_type
    when 'Bill'
      redirect_to :controller => '/bill', :action => (c.is_news? ? 'news' : 'blogs'), :id => c.commentariable.ident
    when 'Person'
      redirect_to :controller => '/people', :action => (c.is_news? ? 'news' : 'blogs'), :id => c.commentariable
    when 'UpcomingBill'
      redirect_to :controller => '/bill', :action => 'upcoming', :id => c.commentariable
    end
  end
  
  def destroy
    @commentary = Commentary.find(params[:id])
    
    case @commentary.commentariable_type
    when 'Bill'
      @redirect_controller = '/bill'
      @redirect_action = 'show'
      @redirect_id = @commentary.commentariable.ident
    when 'Person'
      @redirect_controller = '/people'
      @redirect_action = 'show'
      @redirect_id = @commentary.commentariable
    when 'UpcomingBill'
      @redirect_controller = '/bill'
      @redirect_action = 'upcoming'
      @redirect_id = @commentary.commentariable
    end 
    
    @commentary.status = 'DELETED'
    @commentary.is_ok = false
    @commentary.save
    
    @commentary.commentariable.decrement!(@commentary.is_news ? :news_article_count : :blog_article_count)
    
    flash[:notice] = 'Commentary was deleted.'    
    
    redirect_to :controller => @redirect_controller, :action => @redirect_action, :id => @redirect_id
  end
end
