class NotebookItemsController < ApplicationController
  helper :profile
  helper :political_notebooks
  before_filter :notebook_env, :except => :remove_item


  def create
    return false unless @can_edit
    
    valid_types = %w[NotebookVideo NotebookLink NotebookNote]
    try_type = params[:item_type]
    use_type = (valid_types.include? try_type) ? try_type : nil

    unless use_type.blank?
      @item = use_type.constantize.new(params[use_type.tableize.singularize])
      @item.political_notebook = @political_notebook
      @success = @item.save      
      
      @from_bookmarklet = (params[:from_bookmarklet] == 'true') if @success
    end

    respond_to do |format|      
      format.js        
    end
  end

  def remove_item
    if current_user
      item = NotebookItem.find(params[:id])
      current_user.political_notebook.notebook_items.destroy(item)
      flash[:notice] = "Item removed."
      redirect_to political_notebook_path({:login =>current_user.login, :page => params[:page]})
    else
      redirect_to :controller => 'index'
    end
  end


  def feed
    if @group 
      unless @group.publicly_visible?
        redirect_to groups_path
        return
      end
    else
      # since rss readers can't log into OC accounts, just see if the user has their PN privacy to 'everyone'
      unless @user.can_view('my_political_notebook',nil)
        flash[:notice] = "You don't have permission to subscribe to that user's political notebook!"
        redirect_to :controller => 'index'
        return
      end
    end
    
    @items = @political_notebook.notebook_items.find(:all, :limit => 20)
    render :layout => false
  end
  
  def update
    return false unless @can_edit
    
    @notebook_item = NotebookItem.find(params[:notebook_item][:id])


    @success = @notebook_item.update_attributes(params[:notebook_item])
      
    respond_to do |format| 
      format.js
    end
  end
  
protected
  def notebook_env
    get_user_or_group
    get_notebook
    set_title
    set_profile_nav_location
  end
  
  def set_title
    if @group
      @page_title = "#{@group.name} Activity Stream"
    else
      @page_title = "#{@user.login}'s Profile"
    end  
  end

  def set_profile_nav_location
  	@title_class = "tab-nav"    
    @profile_nav = @user    
  end

  def get_user_or_group
    if params[:group_id].blank?
      @user = User.find_by_login(params[:login])
    else
      @group = Group.find(params[:group_id])
    end
  end

  def get_notebook
    if @group
      @political_notebook = PoliticalNotebook.find_or_create_from_group(@group)    
    else
      @political_notebook = PoliticalNotebook.find_or_create_from_user(@user)    
    end
    
    @can_edit = @political_notebook.can_edit?(current_user)
    @can_view = @political_notebook.can_view?(current_user)
  end

end