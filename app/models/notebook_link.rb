#class NotebookLink < ActiveRecord::Base
class NotebookLink < NotebookItem
  require 'hpricot'
  require 'open-uri'
    
  validates_presence_of :url, :title

  # because the table uses STI a regular polymorphic association doesn't work
  has_many :comments, :foreign_key => 'commentable_id', :conditions => "commentable_type='NotebookLink'"
  
  def is_internal?
    !notebookable_type.blank? && !notebookable_id.blank?
  end
  
  def init_from_notebookable(notebookable)
    case notebookable.class.to_s
    when 'Bill'
      self.title = "OpenCongress: #{notebookable.title_short}" if self.title.blank?
      self.url = "internal"
    when 'Subject'
      self.title = "OpenCongress: #{notebookable.term}" if self.title.blank?
      self.url = "internal"      
    when 'Person'
      self.title = "OpenCongress: #{notebookable.name}" if self.title.blank?
      self.url = "internal"      
    when 'Commentary'
      self.title = notebookable.title if self.title.blank?
      self.url = notebookable.url
    end    
  end
  
  def count_times_bookmarked
    if self.notebookable
      #return NotebookItem.count(:conditions => ["notebookable_type = ? AND notebookable_id = ?", self.notebookable_type, self.notebookable_id])
      return User.count(:include => :notebook_items, :conditions => ["notebook_items.notebookable_type = ? AND notebook_items.notebookable_id = ?", self.notebookable_type, self.notebookable_id])

    else
      return User.count(:include => :notebook_items, :conditions => ["notebook_items.url = ?", self.url])
      #return NotebookItem.count(:conditions => ["url = ?", self.url])
    end
  end

  def other_users_bookmarked
    if self.notebookable
      return User.find(:all, :include => :notebook_items, :conditions => ["notebook_items.notebookable_type = ? AND notebook_items.notebookable_id = ? AND users.id <> ?", self.notebookable_type, self.notebookable_id, self.political_notebook.user.id])
    else
      return User.find(:all, :include => :notebook_items, :conditions => ["notebook_items.url = ? AND users.id <> ?", self.url, self.political_notebook.user.id])
    end
  end


  def before_create
#    doc = Hpricot(open(self.url))
#    title = (doc/"title").inner_html
#    self.title = title unless title.blank?
  end

end
