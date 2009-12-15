class TwitterConfigsController < ApplicationController
  # GET /twitter_configs
  # GET /twitter_configs.xml
  
  before_filter :login_required
  before_filter :get_user
    
  def index
    @twitter_config = @user.twitter_config
    unless @twitter_config
      redirect_to '/twitter' and return
    end
    respond_to do |format|
      format.html # show.html.erb
    end

  end

  # GET /twitter_configs/1
  # GET /twitter_configs/1.xml
  def show
    @twitter_config = @user.twitter_config

    unless @twitter_config
      redirect_to '/twitter' and return
    end

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @twitter_config }
    end
  end

  # GET /twitter_configs/1/edit
  def edit
    @twitter_config = @user.twitter_config
    unless @twitter_config
      redirect_to '/twitter' and return
    end
  end

  # PUT /twitter_configs/1
  # PUT /twitter_configs/1.xml
  def update
    @twitter_config = @user.twitter_config
    unless @twitter_config
      redirect_to '/twitter' and return
    end
    
    respond_to do |format|
      if @twitter_config.update_attributes(params[:twitter_config])
        flash[:notice] = 'TwitterConfig was successfully updated.'
        format.html { redirect_to(@twitter_config) }
        format.xml  { head :ok }
      else
        format.html { render :action => 'edit' }
        format.xml  { render :xml => @twitter_config.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /twitter_configs/1
  # DELETE /twitter_configs/1.xml
  def destroy
    @twitter_config = @user.twitter_config
    unless @twitter_config
      redirect_to '/twitter' and return
    end    
    @twitter_config.destroy

    respond_to do |format|
      format.html { redirect_to(twitter_configs_url) }
      format.xml  { head :ok }
    end
  end
  
  private
  def get_user
    @user = current_user
  end
  
end
