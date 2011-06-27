class PoliticalNotebooksController < ApplicationController
  require 'hpricot'
  require 'open-uri'
  require 'timeout'
  
  helper :profile
  before_filter :login_required, :only => :bookmarklet_add
  before_filter :get_user, :set_title, :set_profile_nav_location, :except => :bookmarklet_add
  before_filter :get_notebook, :except => ['update_privacy','bookmarklet_add']

  def show
    @atom = {'link' => url_for(:only_path => false, :controller => 'notebook_items', :action => 'feed'), 'title' => "#{@user.login}'s My Political Notebook Feed"}
    @hide_atom = true
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @political_notebook }
    end
  end

  def update_privacy
    @user = current_user
    params[:privacy_option].delete("user_id")
    @user.privacy_option.update_attributes(params[:privacy_option])
    redirect_to political_notebook_path({:login =>current_user.login})
  end

  def bookmarklet_add    
    @user = current_user
    @political_notebook = current_user.political_notebook
    @can_view = @can_edit = true
    @items = @political_notebook.notebook_items.paginate(:page => 1, :per_page => 5)
    @from_bookmarklet = true
    
    @page_title = "My Political Notebook"
    @title_class = "tab-nav notebook"    
    @profile_nav = @user
    stc = ScrapeToolsController.new

    # check for youtube for now
    if params[:url] =~ /^http:\/\/www.youtube.com\//

      @notebook_video = NotebookLink.new
      @notebook_video.url = params[:url]
      @notebook_video.embed = get_youtube_embed(params[:url])
      @notebook_video.title = get_url_title(params[:url])
      
    else
      @notebook_link = NotebookLink.new
      @notebook_link.url = params[:url]
      @notebook_link.title = get_url_title(params[:url])
    end
    
    render :action => 'show'
  end
  
private
  def set_title
    if @user == current_user
      @page_title = "My Political Notebook"
    else
      @page_title = "#{@user.login}'s Political Notebook"    
    end
  end

  def set_profile_nav_location
  	@title_class = "tab-nav notebook"    
    @profile_nav = @user    
  end

  def get_user
    @user = User.find_by_login(params[:login])
  end

  def get_notebook
    @political_notebook = PoliticalNotebook.find_or_create_from_user(@user)
    @page = params[:page] ||= 1
    @tag = params[:tag] ||= nil   
    @type = params[:type] ||= nil
    if @tag && @type
      @items = @political_notebook.notebook_items.tagged_with(@tag, :conditions => ["type = ?", @type])
    elsif @tag
      @items = @political_notebook.notebook_items.tagged_with @tag
    elsif @type
      @items = @political_notebook.notebook_items.find(:all, :conditions => ["type = ?", @type])
    else
      @items = @political_notebook.notebook_items
    end
    @items = @items.paginate(:page => @page, :per_page => 5)
    @can_edit = is_users_notebook?
    @can_view = @political_notebook.can_view?(current_user)
  end
  
  def is_users_notebook?
    return false unless logged_in?
    return current_user == @political_notebook.user
  end
  
  def get_url_title(url)
    title = ""
    unless url.blank?
      regex = /(ftp|http|https):\/\/(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?/    
      if url =~ regex
        begin
          Timeout::timeout(3) {
            doc = Hpricot(open(url))
            title = (doc/"title").inner_html
          }
        rescue Timeout::Error
          title = ""
        end
      end
    end
    title
  end

  def get_youtube_embed(url)
    embed = ""
    unless url.blank?
      regex = /(ftp|http|https):\/\/(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?/    
      if url =~ regex
        doc = Hpricot(open(url))
        doc.at("input#embed_code")['value']
        embed = CGI::unescapeHTML(doc.at("input#embed_code")['value'])
      end
    end
    embed
  end 
end
