class UserWarning < ActiveRecord::Base

  belongs_to :user
  belongs_to :admin, :class_name => "User", :foreign_key => :warned_by  

end
