class Admin::UserWarningsController < Admin::IndexController
  before_filter :admin_login_required
  skip_before_filter :store_location


  def show
    @user = User.find_by_id(params[:id], :include => [:user_warnings])
  end
  
  def top_warned
    @top_warned = UserWarning.count(:all, :group => "user_id", :order => "count_all desc")
  end

end
