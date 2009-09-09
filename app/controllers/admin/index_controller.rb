class Admin::IndexController < ApplicationController
  before_filter :login_required
  before_filter :no_users
  before_filter :admin_styles

  def index
  end
  
  def session_list
    @session = CongressSession.new
    @sessions = CongressSession.find(:all, :conditions => ["date >= ?", 1.day.ago], :limit => 10)
  end
  
  def session_toggle
    session = CongressSession.find(params[:id])
    session.is_in_session = !session.is_in_session
    session.save
    
    redirect_to :action => 'session_list'
  end
  
  def session_new
    new_session = CongressSession.new(params[:congress_session])
    
    dupe_session = CongressSession.find_by_date_and_chamber(new_session.date, new_session.chamber)
    if dupe_session
      #just set the status
      dupe_session.is_in_session = true
      dupe_session.save
       
      new_session.destroy
    else
      new_session.is_in_session = true
      new_session.save
    end
    
    flash[:notice] = "Session added."
    redirect_to :action => 'session_list'
  end
  
  
  def admin_styles
    @admin_styles = true
  end
  
end
