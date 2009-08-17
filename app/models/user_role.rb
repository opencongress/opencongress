class UserRole < ActiveRecord::Base
  has_many :users
end
