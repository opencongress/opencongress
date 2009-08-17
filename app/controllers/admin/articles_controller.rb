class Admin::ArticlesController < Admin::IndexController
  before_filter :can_blog
  
  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }
         
  cache_sweeper :article_sweeper, :only => [ :destroy, :update ]
  
  public         
    def index
      list
      render :action => 'list'
    end
  
    def list
      @articles = Article.paginate(:all, :order => "created_at desc", :per_page => 30, :page => params[:page])
    end

    def show
      @article = Article.find(params[:id])
    end

    def new
      @article = Article.new
    end

    def create
      if @article = Article.create(params[:article])
        @article.user_id = current_user.id
        @article.save
        
        expire_page :controller => '/blog'
        expire_page :controller => '/articles'
        expire_page :controller => '/index'
        expire_page :controller => '/articles', :action => 'view', :id => @article
        
        flash[:notice] = 'Article was successfully created.'
        redirect_to :action => 'list'
      else
        render :action => 'new'
      end
    end

    def edit
      @article = Article.find(params[:id])
    end

    def edit_blogroll
      a = Article.find_by_title("***BLOGROLL***")
      if a
        flash[:notice] = "Make sure title stays '***BLOGROLL***' and the published button stays off!"
        redirect_to :action => 'edit', :id => a.id
      else
        flash[:error] = "Couldn't find blogroll in DB!"
        redirect_to :action => 'list'
      end
    end
    
    def update
      @article = Article.find(params[:id])
      if @article.update_attributes(params[:article])
        
        expire_page :controller => '/blog'
        expire_page :controller => '/articles'
        expire_page :controller => '/index'
        expire_page :controller => '/articles', :action => 'view', :id => @article
        
        flash[:notice] = 'Article was successfully updated.'
        redirect_to :action => 'show', :id => @article
      else
        render :action => 'edit'
      end
    end

    def destroy
      Article.find(params[:id]).destroy
      redirect_to :action => 'list'
    end
  
end
