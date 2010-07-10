class Admin::IndexController < ApplicationController
  before_filter :login_required
  before_filter :no_users
  before_filter :admin_styles

  def index
  end
  
  def session_list
    
    unless params[:houseDates].blank?
      dates = params[:houseDates].split(/,/)

      CongressSession.update_all("is_in_session='f'", "date >= '#{1.day.ago}' AND chamber = 'house'")
      dates.each do |d|
        date = Date.parse(d)
        session = CongressSession.find(:first, :conditions => ["chamber='house' AND date = ?", date])
        if session
          session.is_in_session = true
          session.save
        else
          CongressSession.create(:chamber => 'house', :date => date, :is_in_session => true)
        end
      end      
    end
    
    unless params[:senateDates].blank?
      dates = params[:senateDates].split(/,/)

      CongressSession.update_all("is_in_session='f'", "date >= '#{1.day.ago}' AND chamber = 'senate'")
      dates.each do |d|
        date = Date.parse(d)
        session = CongressSession.find(:first, :conditions => ["chamber='senate' AND date = ?", date])
        if session
          session.is_in_session = true
          session.save
        else
          CongressSession.create(:chamber => 'senate', :date => date, :is_in_session => true)
        end
      end      
    end

    @house_sessions = CongressSession.find(:all, :conditions => ["date >= ? AND chamber='house' AND is_in_session='t'", 1.day.ago])
    @senate_sessions = CongressSession.find(:all, :conditions => ["date >= ? AND chamber='senate' AND is_in_session='t'", 1.day.ago])
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
