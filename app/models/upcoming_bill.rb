class UpcomingBill < ActiveRecord::Base
  
  has_many :news, :as => :commentariable, :class_name => 'Commentary', :order => 'commentaries.date DESC', :conditions => "commentaries.is_ok = 't' AND commentaries.is_news='t'"
  has_many :blogs, :as => :commentariable, :class_name => 'Commentary', :order => 'commentaries.date DESC', :conditions => "commentaries.is_ok = 't' AND commentaries.is_news='f'"
  
  has_many :comments, :as => :commentable
  has_many :friend_emails, :as => :emailable, :order => 'created_at'
  
  def display_object_name
    "upcoming bill"
  end 
  
  def to_param
    "#{id}-#{title.gsub(/[^a-z0-9]+/i, '-')}"
  end
end