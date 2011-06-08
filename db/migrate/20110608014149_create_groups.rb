class CreateGroups < ActiveRecord::Migration
  def self.up
    create_table :groups do |t|
      t.string :name
      t.text :description
      t.string :picture_file
      t.string :join_type
      t.string :invite_type
      
      t.timestamps
    end

    create_table :groups_users do |t|
      t.integer :group_id
      t.integer :user_id
      t.string :status
      
      t.timestamps
    end

    create_table :group_invites do |t|
      t.integer :user_id
      t.string :email
      
      
      t.timestamps
    end
    
    create_table :group_join_requests do |t|
      t.integer :user_id
      t.integer :group_id
      
      
      t.timestamps
    end
    
    ## join all users to two default groups
    
  end

  def self.down
    drop_table :groups
    drop_table :groups_users
    drop_table :group_invite
    drop_table :group_join_requests
  end
end
