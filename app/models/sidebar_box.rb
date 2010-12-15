class SidebarBox < ActiveRecord::Base
  belongs_to :sidebarable, :polymorphic => true
  
end
