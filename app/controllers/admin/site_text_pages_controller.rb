class Admin::SiteTextPagesController < Admin::IndexController
  before_filter :can_text
  # GET /site_text_pages
  # GET /site_text_pages.xml
  def index
    @site_text_pages = SiteTextPage.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @site_text_pages }
    end
  end

  # GET /site_text_pages/1
  # GET /site_text_pages/1.xml
  def show
    @site_text_page = SiteTextPage.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @site_text_page }
    end
  end

  # GET /site_text_pages/new
  # GET /site_text_pages/new.xml
  def new
    @site_text_page = SiteTextPage.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @site_text_page }
    end
  end

  # GET /site_text_pages/1/edit
  def edit
    if params[:page_text_editable_id]
      page_params = site_text_params_string(params[:pageparams])

      @site_text_page_editing = SiteTextPage.find_or_create_by_page_text_editable_id_and_page_text_editable_type_and_page_params(
                                      params[:page_text_editable_id], params[:page_text_editable_type], page_params)
                                            
    elsif params[:pageparams]
      page_params = site_text_params_string(params[:pageparams])
      @site_text_page_editing = SiteTextPage.find_or_create_by_page_params(page_params)
    else
      @site_text_page_editing = SiteTextPage.find(params[:id])
    end
  end

  # POST /site_text_pages
  # POST /site_text_pages.xml
  def create
    @site_text_page = SiteTextPage.new(params[:site_text_page])

    respond_to do |format|
      if @site_text_page.save
        flash[:notice] = 'SiteTextPage was successfully created.'
        format.html { redirect_to(@site_text_page) }
        format.xml  { render :xml => @site_text_page, :status => :created, :location => @site_text_page }
      else
        format.html { render :action => 'new' }
        format.xml  { render :xml => @site_text_page.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /site_text_pages/1
  # PUT /site_text_pages/1.xml
  def update
    @site_text_page = SiteTextPage.find(params[:id])

    respond_to do |format|
      if @site_text_page.update_attributes(params[:site_text_page])
        flash[:notice] = 'SiteTextPage was successfully updated.'
        format.html { redirect_to("/?#{@site_text_page.page_params}") }
        format.xml  { head :ok }
      else
        format.html { render :action => 'edit' }
        format.xml  { render :xml => @site_text_page.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /site_text_pages/1
  # DELETE /site_text_pages/1.xml
  def destroy
    @site_text_page = SiteTextPage.find(params[:id])
    @site_text_page.destroy

    respond_to do |format|
      format.html { redirect_to(site_text_pages_url) }
      format.xml  { head :ok }
    end
  end
end
