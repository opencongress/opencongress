class Admin::SiteTextController < Admin::IndexController
  before_filter :can_text
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @site_texts = SiteText.paginate(:all, :per_page => 30, :page => params[:page])
  end

  def show
    @site_text = SiteText.find(params[:id])
  end

  def new
    @site_text = SiteText.new
  end

  def create
    @site_text = SiteText.new(params[:site_text])
    if @site_text.save
      flash[:notice] = 'SiteText was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    if params[:pageparams]
      page_path = params[:pageparams].keys.sort.collect{|k| "#{k}=#{params[:pageparams][k]}"}.join("&")
      @site_text = SiteText.find_by_page_path(page_path)
      if @site_text.nil?
        @site_text = SiteText.new
      end
    else
      @site_text = SiteText.find(params[:id])
    end
  end

  def update
    @site_text = SiteText.find(params[:id])
    if @site_text.update_attributes(params[:site_text])
      flash[:notice] = 'SiteText was successfully updated.'
      redirect_to :action => 'show', :id => @site_text
    else
      render :action => 'edit'
    end
  end

  def destroy
    SiteText.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
  
  def manage
    logger.warn "HERE's the params: #{params[:pageparams].to_s}"
  end
end
