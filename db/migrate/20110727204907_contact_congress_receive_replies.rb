class ContactCongressReceiveReplies < ActiveRecord::Migration
  def self.up
    add_column :contact_congress_letters, :receive_replies, :boolean, :default => true
  end

  def self.down
    remove_column :contact_congress_letters, :receive_replies
  end
end
