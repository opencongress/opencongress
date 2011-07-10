class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :commentable, :polymorphic => true
  
  with_options :foreign_key => 'commentable_id' do |c|
    c.belongs_to :bill
    c.belongs_to :person
    c.belongs_to :article
    c.belongs_to :sector
    c.belongs_to :committee
    c.belongs_to :subject
    c.belongs_to :upcoming_bill
    c.belongs_to :notebook_note
    c.belongs_to :notebook_link
  end
  has_many :comment_scores
  
  scope :users_only, :conditions => ["comments.user_id IS NOT NULL"]
  scope :user_bill_support, :include => [:user, {:bill => :bill_votes}], :conditions => ["users.id = bill_votes.id AND users.id = comments.user_id AND bill_votes.support = ?", 0]
  scope :user_bill_oppose, :include => [:user, {:bill => :bill_votes}], :conditions => ["users.id = bill_votes.id AND users.id = comments.user_id AND bill_votes.support = ?", 1]
  scope :useful, :conditions => ["comments.plus_score_count - comments.minus_score_count DESC > 0"]
  scope :useless, :conditions => ["comments.plus_score_count - comments.minus_score_count DESC < 0"]
  scope :most_useful, :order => ["comments.plus_score_count - comments.minus_score_count DESC"], :limit => 3  
  scope :uncensored, :conditions => ["censored != ?", true]
  
  apply_simple_captcha
  validates_presence_of :comment, :message => " : You must enter a comment."
  validates_length_of :comment, :in => 1..1000, :too_short => " : Your comment is not verbose enough, write more.", :too_long => " : Your comment is too verbose, keep it under 1000 characters."

  acts_as_nested_set :scope => :root
  
  def score_count_sum
    plus_score_count.to_i - minus_score_count.to_i
  end
  
  def score_count_all
    plus_score_count.to_i + minus_score_count.to_i
  end

  def commentable_link
    return self.parent.commentable_link if self.commentable_type.nil?

    obj = Object.const_get(self.commentable_type)
    specific_object = obj.find_by_id(self.commentable_id)

    case self.commentable_type
    when 'Person', 'Committee', 'Article'
      {:controller => self.commentable_type.pluralize.downcase, :action => 'show', :id => specific_object.to_param}
    when 'Bill'
      {:controller => 'bill', :action => 'show', :id => specific_object.ident}
    when 'Subject'
      {:controller => 'issue', :action => 'show', :id => specific_object.to_param}
    when 'BillTextNode'
      {:controller => 'bill', :action => 'text', :id => specific_object.bill_text_version.bill.ident, 
              :version => self.commentable.bill_text_version.version, :nid => self.commentable.nid }
    else
      {:controller => 'index' }
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
      return {:controller => 'bill', :action => 'show', :id => specific_object.ident, :goto_comment => self.id}
    elsif self.commentable_type == "Person"
      return {:controller => 'people', :action => 'show', :id => specific_object.to_param, :goto_comment => self.id}
    elsif self.commentable_type == "Subject"
      return {:controller => 'issue', :action => 'comments', :id => specific_object.to_param, :comment_page => self.page}
    elsif self.commentable_type == "Article"
      return {:controller => 'articles', :action => 'view', :id => specific_object.to_param, :goto_comment => self.id}
    elsif self.commentable_type == "Committee"
      return {:controller => 'committees', :action => 'show', :id => specific_object.to_param}      
    elsif self.commentable_type == "BillTextNode"
      return {:controller => 'bill', :action => 'text', :id => specific_object.bill_text_version.bill.ident, 
              :version => self.commentable.bill_text_version.version, :nid => self.commentable.nid }
    else
      return {:controller => 'index' }
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
      return {:controller => 'people', :action => 'comments', :id => specific_object.to_param, :comment_page => self.page}
    elsif self.commentable_type == "Subject"
      return {:controller => 'issue', :action => 'comments', :id => specific_object.to_param, :comment_page => self.page}
    elsif self.commentable_type == "Article"
      return {:controller => 'articles', :action => 'view', :id => specific_object.to_param}
    elsif self.commentable_type == "Committee"
      return {:controller => 'committees', :action => 'show', :id => specific_object.to_param}
    elsif self.commentable_type == "BillTextNode"
      return {:controller => 'bill', :action => 'text', :id => specific_object.bill_text_version.bill.ident,
              :version => self.commentable.bill_text_version.version, :nid => self.commentable.nid }
    else
      return {:controller => 'index' }
    end
  end

  def page
      if page_result = Comment.find_by_sql(["select comment_page(id, commentable_id, commentable_type, ?) as page_number from comments where id = ?", Comment.per_page, self.id])[0]
        return page_result.page_number
      else
        return 1
      end
  end

  def commentable_title
    return self.parent.commentable_title if self.commentable_type.nil?
    
    obj = Object.const_get(self.commentable_type)
    specific_object = obj.find_by_id(self.commentable_id)
    if self.commentable_type == "Bill"
      return specific_object.typenumber
    elsif self.commentable_type == "Person"
      return specific_object.name
    elsif self.commentable_type == "Subject"
      return specific_object.term
    elsif self.commentable_type == "Article"
      return specific_object.title
    else
      return {:controller => 'index' }
    end

  end
  
  def atom_id
    "tag:opencongress.org,#{created_at.strftime("%Y-%m-%d")}:/comment/#{id}"
  end

  def self.full_text_search(q, options = {})    
    congresses = options[:congresses].nil? ? [Settings.default_congress] : options[:congresses]

    s_count = Comment.count(:all, 
                            :joins => "LEFT OUTER JOIN bills ON (bills.id = comments.commentable_id AND comments.commentable_type='Bill')",
                            :conditions => ["(comments.fti_names @@ to_tsquery('english', ?) AND comments.commentable_type='Bill' AND bills.session IN (?)) OR
                                             (comments.fti_names @@ to_tsquery('english', ?) AND comments.commentable_type != 'Bill')", q, congresses, q])
    
    
    # Note: This takes (current_page, per_page, total_entries)
    # We need to do this so we can put LIMIT and OFFSET inside the subquery.
    WillPaginate::Collection.create(options[:page], 12, s_count) do |pager|
      # perfom the find.
      # The subquery is here so we don't run ts_headline on all rows, which takes a long long time...
      # See http://www.postgresql.org/docs/8.4/static/textsearch-controls.html
      pager.replace Comment.find_by_sql(["SELECT
          comments.*, ts_headline(comment, ?) as headline
        FROM (SELECT * from comments LEFT OUTER JOIN bills ON (bills.id = comments.commentable_id AND comments.commentable_type='Bill')
          WHERE ((comments.fti_names @@ to_tsquery('english', ?) AND comments.commentable_type='Bill' AND bills.session IN (?)) OR
                 (comments.fti_names @@ to_tsquery('english', ?) AND comments.commentable_type != 'Bill'))
          ORDER BY comments.created_at DESC LIMIT ? OFFSET ?) AS comments", q, q, congresses, q, pager.per_page, pager.offset])
    end
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
