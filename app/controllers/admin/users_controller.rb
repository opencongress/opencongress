class Admin::UsersController < Admin::IndexController
  before_filter :admin_login_required
  
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
     offset = params[:page] ? (params[:page].to_i - 1) * 30 : 0
    @query = params[:q]
    unless params[:q].blank?
      @solr_results = User.find_by_solr("#{@query} OR #{@query}~0.5", :limit => 30, :offset => offset)
    else
      @solr_results = User.find_by_solr("[* TO *]",  :limit => 30, :offset => offset)
    end
    @users = WillPaginate::Collection.create((params[:page] && params[:page].to_i > 0 ? params[:page] : 1), 30) do |pager|
       result = @solr_results.docs #results_2
       pager.replace(result)
       pager.total_entries = @solr_results.total_hits
    end
	end

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:notice] = 'User was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      flash[:notice] = 'User was successfully updated.'
      redirect_to :action => 'show', :id => @user
    else
      render :action => 'edit'
    end
  end

  def make_watch_dog
     @user = User.find_by_id(params[:id])
     if @user.definitive_district
       WatchDog.destroy_all("district_id = #{@user.definitive_district}")
       wd =  WatchDog.find_or_initialize_by_district_id_and_user_id(@user.definitive_district, @user.id)
       wd.is_active = true
       wd.save
     end
     redirect_to :action => 'edit', :id => @user
  end

  def resend_confirmation
     @user = User.find_by_id(params[:id])
     UserNotifier.deliver_signup_notification(@user)
     redirect_to :action => 'edit', :id => @user
  end 

  def activate_user
    @user = User.find_by_id(params[:id])
    @user.activate
    redirect_to :action => 'edit', :id => @user
  end

  def destroy
    User.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
