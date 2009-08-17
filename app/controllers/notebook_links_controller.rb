class NotebookLinksController < NotebookItemsController


  def create
    return false unless @can_edit
    
    # if we don't have params to create an internal link, call the super to create an external one
    if params[:id].blank? || params[:type].blank?
      super
    else
      @notebookable = Object.const_get(params[:type]).find_by_id(params[:id])
      
      @item = NotebookLink.new(params[:notebook_link])   
      @item.notebookable = @notebookable    
      @item.political_notebook = @political_notebook      
      @item.init_from_notebookable(@notebookable)
      
      @success = @item.save
      
      respond_to do |format| 
        format.js {
          render :update do |page|
            if @success
              page.replace_html(params[:from],'Added to MyPN')
              page.show(params[:msgDiv])
              page.hide(params[:formFields])            
              page.replace_html(params[:msgDiv],"The #{params[:type]} was added to Your Political Notebook.<br /><a href='#{political_notebook_path({:login =>current_user.login})}'>Visit Your Political Notebook</a>.")
            else
              page.alert("All fields marked with an * are required.")
            end
          end
        }
      end
#      redirect_to political_notebook_path(:login => current_user.login)
    end
  end

  def faceform
    @object = Object.const_get(params[:type]).find_by_id(params[:id])        
    render :layout => false
  end

#private 

  # GET /notebook_links
  # GET /notebook_links.xml
  def index
    @notebook_links = NotebookLink.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @notebook_links }
    end
  end

  # GET /notebook_links/1
  # GET /notebook_links/1.xml
  def show
    @notebook_link = NotebookLink.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @notebook_link }
    end
  end

  # GET /notebook_links/new
  # GET /notebook_links/new.xml
  def new
    @notebook_link = NotebookLink.new

    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @notebook_link }
    end
  end

  # GET /notebook_links/1/edit
  def edit
    @notebook_link = NotebookLink.find(params[:id])
  end


  # PUT /notebook_links/1
  # PUT /notebook_links/1.xml
  def update
    @notebook_link = NotebookLink.find(params[:id])

    respond_to do |format|
      if @notebook_link.update_attributes(params[:notebook_link])
        flash[:notice] = 'NotebookLink was successfully updated.'
        format.html { redirect_to(@notebook_link) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @notebook_link.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /notebook_links/1
  # DELETE /notebook_links/1.xml
  def destroy
    @notebook_link = NotebookLink.find(params[:id])
    @notebook_link.destroy

    respond_to do |format|
      #format.html { redirect_to(notebook_links_url) }
      format.html { redirect_to political_notebook_path({:login =>current_user.login}) }
      format.xml  { head :ok }
    end
  end



end
