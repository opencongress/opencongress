class AddPreviousLoginDateToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :previous_login_date, :datetime
  end

  def self.down
    remove_column :users, :previous_login_date
  end
end
