class UserFeedsController < ApplicationController
  
  before_filter :get_user_login
  before_filter :is_permitted_tracked?, :except => [:actions,:comments,:votes]
  before_filter :is_permitted_actions?, :only => [:actions,:comments,:votes]
  skip_before_filter :store_location

  def tracked_items

    @title = "All things I'm Tracking"

    @tracked_issues = @user.issue_bookmarks
    @tracked_bills = @user.bill_bookmarks
    @tracked_people = @user.representative_bookmarks
    @tracked_committees = @user.committee_bookmarks

    @items = []
    
    @tracked_issues.each do |i|
      @items.concat(i.subject.latest_major_actions(5))
    end
    @tracked_people.each do |p|
        @items.concat(p.person.last_x_bills(5).to_a)
        @items.concat(p.person.votes(10).to_a)
    end
    
    @tracked_bills.each do |b|
      @items.concat(b.bill.last_5_actions.to_a)
    end
    
    @tracked_committees.each do |b|
      logger.info b.bookmarkable.latest_reports(5).to_a.to_yaml
      logger.info b.bookmarkable.latest_major_actions(5).to_a.to_yaml
      @items.concat(b.bookmarkable.latest_reports(5).to_a)
      @items.concat(b.bookmarkable.latest_major_actions(5))
    end
#    logger.info @items.to_yaml
    @items.flatten!
    @items.sort! { |x,y| y.rss_date <=> x.rss_date }
    expires_in 60.minutes, :public => true

    render :action => "tracked_rss.rxml", :layout => false

  end
  
  def committees
    @tracked_committees = @user.committee_bookmarks
     @items = []
     @tracked_committees.each do |b|
       @items.concat(b.bookmarkable.latest_reports(5).to_a)
       @items.concat(b.bookmarkable.latest_major_actions(5))
     end
     @items.flatten!
     @items.sort! { |x,y| y.rss_date <=> x.rss_date }
     expires_in 60.minutes, :public => true
     render :action => "committees.xml.builder", :layout => false
  end
  
  def actions
    @items = @user.recent_actions
    expires_in 60.minutes, :public => true
    render :action => "user_actions_rss.rxml", :layout => false
  end
  
  def senators
    @ptype = 'Senators'
    @page_title = "Profile of #{@user.login} - Senators Tracked"
    @bookmarks = @user.senator_bookmarks
     expires_in 60.minutes, :public => true
     @items = []
     @bookmarks.each do |b|
        @items << b.person.last_x_bills(10).to_a
      end
      @items.flatten!
      @items.sort! { |x,y| y.sort_date <=> x.sort_date }

      render :action => "person.rxml", :layout => false
  end
  
  def representatives
    @ptype = 'Representatives'
    @page_title = "Profile of #{@user.login} - Representatives Tracked"
    @bookmarks = @user.representative_bookmarks
     expires_in 60.minutes, :public => true
     @items = []
     @bookmarks.each do |b|
        @items << b.person.last_x_bills(10).to_a
      end
      @items.flatten!
      @items.sort! { |x,y| y.sort_date <=> x.sort_date }

      render :action => "person.rxml", :layout => false
  end
  
  def bills
    @page_title = "Profile of #{@user.login} - Bills Tracked"
    @bookmarks = Bookmark.find_bookmarked_bills_by_user(@user.id)
    @title = "Bills #{params[:login]} is Tracking"
    @items = []
    @bookmarks.each do |b|
      @items << b.bill.last_5_actions.to_a
    end
    @items.flatten!
    @items.sort! { |x,y| y.date <=> x.date }
    expires_in 60.minutes, :public => true
    render :action => "bills.rxml", :layout => false
  end

  def votes

    @page_title = "Profile of #{@user.login} - Bills Voted On"
    @bills_supported = @user.bill_votes.find_all_by_support(0)
    @bills_opposed = @user.bill_votes.find_all_by_support(1)
    @bill_votes = @bills_supported.concat(@bills_opposed)

    @title = "Bills #{params[:login]} supports & opposes"
    @items = []
    @bill_votes.each do |b|
      @items << b.bill.last_5_actions.to_a
    end
    @items.flatten!
    @items.sort! { |x,y| y.date <=> x.date }
    expires_in 60.minutes, :public => true
    render :action => "bills.rxml", :layout => false

  end

  def comments
    @page_title = "Profile of #{@user.login} - Comments"
    @comments = Comment.find(:all, :conditions => ["user_id = ?", @user.id], :order => "created_at DESC", :limit => 20)
    expires_in 60.minutes, :public => true
    render :action => "comments.rxml", :layout => false
  end
  
  def issues
    @page_title = "Profile of #{@user.login} - Issues tracked"
    @bookmarks = Bookmark.find(:all, :conditions => ["bookmarkable_type = ? AND user_id = ?", "Subject", @user.id])
    @title = "Issues I'm Tracking"
    @items = []
    @bookmarks.each do |b|
      @items << b.subject.latest_major_actions(5)
    end
    @items.flatten!
    @items.sort! { |x,y| y.date <=> x.date }
    expires_in 60.minutes, :public => true

    render :action => "bills.rxml", :layout => false
  end

  private
  def get_user_login
    @user = User.find_by_login(params[:login])
    if @user
      return true
    else
      redirect_to '/'
      return false
    end       
  end
  
  def is_permitted_tracked?
    t_user = nil
    t_user = User.find_by_feed_key(params[:key] ? params[:key] : "ASDFASDF")
    if @user.can_view(:my_tracked_items, t_user) == true
      return true
    else
      redirect_to '/'
      return false
    end 
  end
  
  def is_permitted_actions?
    t_user = nil
    t_user = User.find_by_feed_key(params[:key] ? params[:key] : "ASDFASDF")
    if @user.can_view(:my_actions, t_user) == true
      return true
    else
      redirect_to '/'
      return false
    end 
  end
  
end
