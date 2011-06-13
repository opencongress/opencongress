class Group < ActiveRecord::Base
  has_attached_file :group_image, :styles => { :medium => "300x300>", :thumb => "100x100>" }, :path => "#{Settings.group_images_path}/:id/:style/:filename"
  
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_presence_of :user_id
  
  belongs_to :user
  has_many :group_invites
  belongs_to :pvs_category
  
  has_many :comments, :as => :commentable
  
  def to_param
    "#{id}_#{name.gsub(/[^A-Za-z]+/i, '_').gsub(/\s/, '_')}"
  end
  
  def display_object_name
    'Group'
  end
end
