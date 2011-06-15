class Group < ActiveRecord::Base
  has_attached_file :group_image, :styles => { :medium => "300x300>", :thumb => "100x100>" }, :path => "#{Settings.group_images_path}/:id/:style/:filename"
  
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_presence_of :user_id
  
  belongs_to :user
  has_many :group_invites
  belongs_to :pvs_category
  
  has_many :group_members
  has_many :users, :through => :group_members
  
  has_many :group_bill_positions
  has_many :bills, :through => :group_bill_positions
  
  has_many :comments, :as => :commentable
  
  def to_param
    "#{id}_#{name.gsub(/[^A-Za-z]+/i, '_').gsub(/\s/, '_')}"
  end
  
  def display_object_name
    'Group'
  end
  
  def is_member?(user)
    membership = group_members.where(["group_members.user_id=?", user.id]).first
    return (membership && membership.status != 'BOOTED')
  end
  
  def can_join?(user)
    membership = group_members.where(["group_members.user_id=?", user.id]).first
    
    case join_type
    when 'ANYONE', 'REQUEST'
      return (membership.nil? or membership.status != 'BOOTED') ? true  : false
    when 'INVITE_ONLY'
      if membership and membership.status == 'BOOTED'
        return false
      else
        return !group_invites.where(["user_id=?", user.id]).empty?
      end
    end
  end
  
  def can_moderate?(user)
    return true if self.user == user

    membership = group_members.where(["group_members.user_id=?", user.id]).first
    
    return false if membership.nil?
    return true if membership.status == 'MODERATOR'
    
    return false
  end
  
  def can_post?(user)
    return true if self.user == user

    membership = group_members.where(["group_members.user_id=?", user.id]).first
    
    return false if membership.nil?
    
    case post_type
    when 'ANYONE'
      return true
    when 'MODERATOR'  
      return true if membership.status == 'MODERATOR'
    end
    
    return false
  end
  
  def bills_supported
    bills.where("group_bill_positions.position='support'")
  end
  
  def bills_opposed
    bills.where("group_bill_positions.position='oppose'")
  end  
end
