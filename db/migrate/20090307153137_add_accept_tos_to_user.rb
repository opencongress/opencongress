class AddAcceptTosToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :accepted_tos, :boolean, :default => false
    add_column :users, :accepted_tos_at, :datetime
    User.update_all("accepted_tos = false")
  end

  def self.down
    remove_column :users, :accepted_tos
    remove_column :users, :accepted_tos_at
  end
end
