class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :commentable, :polymorphic => true
  belongs_to :bill, :foreign_key => "commentable_id"
  belongs_to :person, :foreign_key => "commentable_id"
  belongs_to :article, :foreign_key => "commentable_id"
  belongs_to :sector, :foreign_key => "commentable_id"
  belongs_to :committee, :foreign_key => "commentable_id"
  belongs_to :subject, :foreign_key => "commentable_id"
  belongs_to :bill_battle, :foreign_key => "commentable_id"
  belongs_to :upcoming_bill, :foreign_key => "commentable_id"
  has_many :comment_scores
  
  named_scope :users_only, :conditions => ["comments.user_id IS NOT NULL"]
  named_scope :user_bill_support, :include => [:user, {:bill => :bill_votes}], :conditions => ["users.id = bill_votes.id AND users.id = comments.user_id AND bill_votes.support = ?", 0]
  named_scope :user_bill_oppose, :include => [:user, {:bill => :bill_votes}], :conditions => ["users.id = bill_votes.id AND users.id = comments.user_id AND bill_votes.support = ?", 1]
  named_scope :useful, :conditions => ["comments.average_rating > 5"]
  named_scope :useless, :conditions => ["comments.average_rating < 5"]
  named_scope :most_useful, :order => ["average_rating desc"], :limit => 3
  named_scope :uncensored, :conditions => ["censored != ?", true]

  
  apply_simple_captcha
  validates_presence_of :comment, :message => "You must enter a comment."
  validates_length_of :comment, :in => 1..1000, :too_short => "comment is not verbose enough, write more.", :too_long => "comment is too verbose, keep it under 1000 characters."

  acts_as_nested_set :scope => :root
#  acts_as_tree
  
  def commentable_link
    return self.parent.commentable_link if self.commentable_type.nil?
    
    obj = Object.const_get(self.commentable_type)
    specific_object = obj.find_by_id(self.commentable_id)
    if self.commentable_type == "Bill"
      return {:controller => "bill", :action => "show", :id => specific_object.ident}
    elsif self.commentable_type == "Person"
      return {:controller => "people", :action => "show", :id => specific_object.to_param}
    elsif self.commentable_type == "Subject"
      return {:controller => "issue", :action => "show", :id => specific_object.to_param}
    elsif self.commentable_type == "Committee"
      return {:controller => "committees", :action => "show", :id => specific_object.to_param}          
    elsif self.commentable_type == "Article"
      return {:controller => "articles", :action => "view", :id => specific_object.to_param}
    elsif self.commentable_type == "BillTextNode"
      return {:controller => "bill", :action => "text", :id => specific_object.bill_text_version.bill.ident, 
              :version => self.commentable.bill_text_version.version, :nid => self.commentable.nid }
    else
      return {:controller => "index" }
    end

  end

  def comment_warn(admin)
    if self.user
      self.user.comment_warn(self, admin)
    end
  end
  
  def page_link
    return self.parent.commentable_link if self.commentable_type.nil?
    
    obj = Object.const_get(self.commentable_type)
    specific_object = obj.find_by_id(self.commentable_id)
    if self.commentable_type == "Bill"
      return {:controller => "bill", :action => "show", :id => specific_object.ident, :goto_comment => self.id}
    elsif self.commentable_type == "Person"
      return {:controller => "people", :action => "show", :id => specific_object.to_param, :goto_comment => self.id}
    elsif self.commentable_type == "Subject"
      return {:controller => "issue", :action => "comments", :id => specific_object.to_param, :comment_page => self.page}
    elsif self.commentable_type == "Article"
      return {:controller => "articles", :action => "view", :id => specific_object.to_param}
    elsif self.commentable_type == "Committee"
      return {:controller => "committees", :action => "show", :id => specific_object.to_param}      
    elsif self.commentable_type == "BillTextNode"
      return {:controller => "bill", :action => "text", :id => specific_object.bill_text_version.bill.ident, 
              :version => self.commentable.bill_text_version.version, :nid => self.commentable.nid }
    else
      return {:controller => "index" }
    end    
  end

  # /admin is messed up - quick fix by ds
  def page_link_admin
    return self.parent.commentable_link if self.commentable_type.nil?

    obj = Object.const_get(self.commentable_type)
    specific_object = obj.find_by_id(self.commentable_id)
    if self.commentable_type == "Bill"
      return "/bill/#{specific_object.ident}/show?goto_comment=#{self.id}"
    elsif self.commentable_type == "Person"
      return {:controller => "people", :action => "comments", :id => specific_object.to_param, :comment_page => self.page}
    elsif self.commentable_type == "Subject"
      return {:controller => "issue", :action => "comments", :id => specific_object.to_param, :comment_page => self.page}
    elsif self.commentable_type == "Article"
      return {:controller => "articles", :action => "view", :id => specific_object.to_param}
    elsif self.commentable_type == "Committee"
      return {:controller => "committees", :action => "show", :id => specific_object.to_param}
    elsif self.commentable_type == "BillTextNode"
      return {:controller => "bill", :action => "text", :id => specific_object.bill_text_version.bill.ident,
              :version => self.commentable.bill_text_version.version, :nid => self.commentable.nid }
    else
      return {:controller => "index" }
    end
  end

  
  def page
      index = self.commentable.comments.find(:all, :order => 'comments.root_id ASC, comments.lft ASC').rindex(self)
      return ((index.to_f / Comment.per_page.to_f) + 1.to_f).floor
  end
  
  def commentable_title
    return self.parent.commentable_title if self.commentable_type.nil?
    
    obj = Object.const_get(self.commentable_type)
    specific_object = obj.find_by_id(self.commentable_id)
    if self.commentable_type == "Bill"
      return specific_object.title_typenumber_only
    elsif self.commentable_type == "Person"
      return specific_object.name
    elsif self.commentable_type == "Subject"
      return specific_object.term
    elsif self.commentable_type == "Article"
      return specific_object.title
    else
      return {:controller => "index" }
    end

  end
  
  def atom_id
    "tag:opencongress.org,#{created_at.strftime("%Y-%m-%d")}:/comment/#{id}"
  end

  def self.full_text_search(q, options = {})
    #count = Comment.count_by_solr(q)
    #comments = Comment.paginate_all_by_solr(q, :page => options[:page], :total_entries => count)
    #comments  
    
    
    total_comments = Comment.count_by_sql(["SELECT count(*) FROM commentaries 
                                         WHERE commentaries.is_ok = 't' AND
                                               commentaries.is_news = '#{is_news}' AND
                                               fti_names @@ to_tsquery('english', ?)", q])
    comments = Comment.find_by_sql(["SELECT commentaries.*, rank(fti_names, ?, 1) as tsearch_rank FROM commentaries 
                                 WHERE commentaries.is_ok = 't' AND
                                       commentaries.is_news = '#{is_news}' AND
                                       fti_names @@ to_tsquery('english', ?)                                       
                                 ORDER BY commentaries.date DESC 
                                 LIMIT #{DEFAULT_SEARCH_PAGE_SIZE}
                                 OFFSET #{DEFAULT_SEARCH_PAGE_SIZE * (options[:page]-1)}", q, q])
  end
  
  # this is simply the standard equality method in active record's base class.  the problem
  # is that acts_as_nested_set overrides this with a comparison method, <=>, that is not very compatible
  # with multiple trees.  it is provided here to override that method.
  def ==(comparison_object)
    comparison_object.equal?(self) ||
    (comparison_object.instance_of?(self.class) &&
    comparison_object.id == id &&
    !comparison_object.new_record?)
  end
end
