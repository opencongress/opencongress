class FriendEmail < ActiveRecord::Base
  acts_as_tree
  belongs_to :emailable, :polymorphic => true
end