class GroupInvite < ActiveRecord::Base
  belongs_to :group
  belongs_to :user
  
  attr_accessor :invite_string
end
