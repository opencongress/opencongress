class Facebook < ActiveRecord::Migration
  def self.up
    create_table :facebook_users do |t| 
      t.column :facebook_uid, :integer
      t.column :facebook_session_key, :string
      t.column :updated_at, :datetime
      t.column :created_at, :datetime
    end
    
    create_table :facebook_user_bills do |t| 
      t.column :facebook_user_id, :integer
      t.column :bill_id, :integer
      t.column :tracking_type, :string      
      t.column :comment, :text      
      t.column :updated_at, :datetime
      t.column :created_at, :datetime
    end
  end
  
  def self.down
    drop_table :facebook_users
    drop_table :facebook_user_bills
  end
end