class Bookmark < ActiveRecord::Base
  belongs_to :bookmarkable, :polymorphic => true
  
  with_options :foreign_key => "bookmarkable_id" do |b|
    b.belongs_to :person, :include => :roles
    b.belongs_to :bill
    b.belongs_to :subject
    b.belongs_to :committee
  end

  validates_uniqueness_of :bookmarkable_id, :scope => [:user_id, :bookmarkable_type]

  # NOTE: install the acts_as_taggable plugin if you
  # want bookmarks to be tagged.
  acts_as_taggable

  # NOTE: Comments belong to a user
  belongs_to :user

  # Helper class method to lookup all comments assigned
  # to all commentable types for a given user.
  def self.find_bookmarks_by_user(user)
    find(:all,
      :conditions => ["user_id = ?", user.id],
      :order => "created_at DESC"
    )
  end

  # Helper class method to look up a commentable object
  # given the commentable class name and id
  def self.find_bookmarkable(commentable_str, commentable_id)
    commentable_str.constantize.find(commentable_id)
  end

  def self.find_bookmarks_by_user_and_person_role(user,role)
#      find_all_by_user_id(User.find_by_login(user).id, 
#            :include => [:person => :roles], 
#            :conditions => ["bookmarkable_type = ? AND roles.role_type = ?", "Person", role])
      with_scope(:find => {:conditions => ["bookmarkable_type = 'Person' AND user_id = ?", user]}) do
         find(:all, :include => [{:person => :roles}], :conditions => ["roles.role_type = ?", role])
      end
  end

  def self.find_bookmarked_bills_by_user(user)
      find_all_by_user_id(user,
            :conditions => ["bookmarkable_type = ?", "Bill"])
  end

end

