class WikiLinksController < ApplicationController
  # GET /admin_wiki_links
  # GET /admin_wiki_links.xml
  def index
    @wiki_links = WikiLink.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @wiki_links }
    end
  end

  # GET /admin_wiki_links/1
  # GET /admin_wiki_links/1.xml
  def show
    @wiki_link = WikiLink.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @wiki_link }
    end
  end

  # GET /admin_wiki_links/new
  # GET /admin_wiki_links/new.xml
  def new
    @wiki_link = WikiLink.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @wiki_link }
    end
  end

  # GET /admin_wiki_links/1/edit
  def edit
    @wiki_link = WikiLink.find(params[:id])
  end

  # POST /admin_wiki_links
  # POST /admin_wiki_links.xml
  def create
    @wiki_link = WikiLink.new(params[:wiki_link])

    respond_to do |format|
      if @wiki_link.save
        flash[:notice] = 'Admin::WikiLink was successfully created.'
        format.html { redirect_to(@wiki_link) }
        format.xml  { render :xml => @wiki_link, :status => :created, :location => @wiki_link }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @wiki_link.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /admin_wiki_links/1
  # PUT /admin_wiki_links/1.xml
  def update
    @wiki_link = WikiLink.find(params[:id])

    respond_to do |format|
      if @wiki_link.update_attributes(params[:wiki_link])
        flash[:notice] = 'Admin::WikiLink was successfully updated.'
        format.html { redirect_to(@wiki_link) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @wiki_link.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /admin_wiki_links/1
  # DELETE /admin_wiki_links/1.xml
  def destroy
    @wiki_link = WikiLink.find(params[:id])
    @wiki_link.destroy

    respond_to do |format|
      format.html { redirect_to(wiki_links_url) }
      format.xml  { head :ok }
    end
  end
end
