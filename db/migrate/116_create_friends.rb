class CreateFriends < ActiveRecord::Migration
  def self.up
    create_table :friends do |t|
      t.column :user_id, :integer
      t.column :friend_id, :integer
      t.column :confirmed, :boolean
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      t.column :confirmed_at, :datetime
    end
  end

  def self.down
    drop_table :friends
  end
end
