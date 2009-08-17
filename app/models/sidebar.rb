class Sidebar < ActiveRecord::Base
  has_many :sidebar_items, :order => 'rank'
end
