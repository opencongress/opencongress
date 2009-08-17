class SidebarItem < ActiveRecord::Base
  belongs_to :sidebar
  belongs_to :bill
  belongs_to :person
  belongs_to :committee
  belongs_to :subject
end
