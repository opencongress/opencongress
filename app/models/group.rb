class Group < ActiveRecord::Base
  has_attached_file :group_image, :styles => { :medium => "300x300>", :thumb => "100x100>" }, :path => "#{Settings.group_images_path}/:id/:style/:filename"
  
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_presence_of :user_id
  
  belongs_to :user
  has_many :group_invites
  belongs_to :pvs_category
  
  has_many :group_members
  has_many :users, :through => :group_members, :order => "users.login ASC"
  
  has_many :group_bill_positions
  has_many :bills, :through => :group_bill_positions
  
  has_many :comments, :as => :commentable
  
  has_one :political_notebook
  
  scope :visible, where(:publicly_visible=>true)
  scope :with_name_or_description_containing, lambda { |q| where(["groups.name ILIKE ? OR groups.description ILIKE ?", "%#{q}%", "%#{q}%"]) }
  scope :in_category, lambda { |category_id| where(:pvs_category_id => category_id) }
  scope :in_state, lambda { |state_id| includes(:state, :district => :state).where(["groups.state_id=? OR districts.state_id=?", state_id, state_id])}

  belongs_to :state
  belongs_to :district
  
  def to_param
    "#{id}_#{name.gsub(/[^A-Za-z]+/i, '_').gsub(/\s/, '_')}"
  end
  
  def display_object_name
    'Group'
  end
  
  def active_members
    users.where("group_members.status != 'BOOTED'")                                             
  end
  
  def owner_or_member?(u)
    is_owner?(u) or is_member?(u)
  end
  
  def is_owner?(u)
    self.user == u
  end
  
  def is_member?(u)
    return false if u == :false
    
    membership = group_members.where(["group_members.user_id=?", u.id]).first
    return (membership && membership.status != 'BOOTED')
  end
  
  def membership(u)
    membership = group_members.where(["group_members.user_id=?", u.id]).first
  end
  
  def can_join?(u)
    return false if u == :false
    
    membership = group_members.where(["group_members.user_id=?", u.id]).first
    
    # if they're already a member, they can't join
    return false if membership or u == self.user
    
    case join_type
    when 'ANYONE', 'REQUEST'
      return (membership.nil? or membership.status != 'BOOTED') ? true  : false
    when 'INVITE_ONLY'
      if membership and membership.status == 'BOOTED'
        return false
      else
        return !group_invites.where(["user_id=?", u.id]).empty?
      end
    end
    
    return false
  end
  
  def can_moderate?(u)
    return false if u == :false
    return true if self.user == u

    membership = group_members.where(["group_members.user_id=?", u.id]).first
    
    return false if membership.nil?
    return true if membership.status == 'MODERATOR'
    
    return false
  end
  
  def can_invite?(u)
    return false if u == :false
    return true if self.user == u

    membership = group_members.where(["group_members.user_id=?", u.id]).first
    
    return false if membership.nil?
    
    case invite_type
    when 'ANYONE'
      return true
    when 'MODERATOR'  
      return true if membership.status == 'MODERATOR'
    end
    
    return false
  end
  
  def can_post?(u)
    return false if u == :false
    return true if self.user == u

    membership = group_members.where(["group_members.user_id=?", u.id]).first
    
    return false if membership.nil?
    
    case post_type
    when 'ANYONE'
      return true
    when 'MODERATOR'  
      return true if membership.status == 'MODERATOR'
    end
    
    return false
  end
  
  def unviewed_posts(u, last_view = nil)
    return 0 if u == :false
    
    membership = group_members.where(["group_members.user_id=?", u.id]).first
    
    return 0 if membership.nil? or membership.status == 'BOOTED' or political_notebook.nil?
    
    return political_notebook.notebook_items.where("created_at > ?", last_view.nil? ? membership.last_view : last_view).size
  end
  
  def bills_supported
    bills.where("group_bill_positions.position='support'")
  end
  
  def bills_opposed
    bills.where("group_bill_positions.position='oppose'")
  end  
end
