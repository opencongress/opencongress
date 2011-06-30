class NotebookVideo < NotebookItem
  require 'hpricot'
  require 'open-uri'
  
  # because the table uses STI a regular polymorphic association doesn't work
  has_many :comments, :foreign_key => 'commentable_id', :conditions => "commentable_type='NotebookVideo'"
  
  validates_presence_of :embed, :title
  before_save :set_xy, :make_embed_transparent
  
  def set_xy
    x = /width="(\d*)"/.match(self.embed)
    self.width = x.nil? ? 425 : x[1].to_i
    y = /height="(\d*)"/.match(self.embed)
    self.height = y.nil? ? 344 : y[1].to_i    
  end

  def count_times_bookmarked
    return User.count(:include => :notebook_items, :conditions => ["notebook_items.url = ?", self.url])
  end

  def other_users_bookmarked
    return User.find(:all, :include => :notebook_items, :conditions => ["notebook_items.embed = ? AND users.id <> ?", self.url, self.political_notebook.user.id])
  end
  
  def make_embed_transparent
    return if self.embed.empty?
    
    hp = Hpricot(self.embed)
    hp.at("embed")['wmode'] = "transparent" unless hp.at("embed").nil?
    (hp/"param").last.after('<param name="wmode" value="transparent" />') unless (hp/"param").empty?
    
    self.embed = hp.to_html
  end
end
