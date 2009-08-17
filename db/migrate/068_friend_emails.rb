class FriendEmails < ActiveRecord::Migration
  def self.up
    create_table :friend_emails do |t|
      t.column "emailable_id", :integer, :null => false
      t.column "emailable_type", :string      
      t.column "created_at", :timestamp      
      t.column "ip_address", :string      
    end
    
    add_index :friend_emails, :created_at
    add_index :friend_emails, :ip_address
    
    add_index :bill_subjects, :subject_id
  end
  
  def self.down
    drop_table :friend_emails
    
    remove_index :bill_subjects, :subject_id
  end
end
