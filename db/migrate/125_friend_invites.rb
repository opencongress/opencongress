class FriendInvites < ActiveRecord::Migration
  def self.up
    create_table :friend_invites do |t| 
      t.column :inviter_id, :integer
      t.column :invitee_email, :string
      t.column :created_at, :datetime
      t.column :invite_key, :string
    end
  end

  def self.down
    drop_table :friend_invites
  end
end