class CreateGroups < ActiveRecord::Migration
  def self.up
    create_table :groups do |t|
      t.integer :user_id
      t.string :name
      t.text :description
      t.string :join_type
      t.string :invite_type
      t.string :website
      t.integer :pvs_category_id

      t.string :group_image_file_name
      t.string :group_image_content_type
      t.integer :group_image_file_size
      t.datetime :group_image_updated_at

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
    drop_table :group_invites
    drop_table :group_join_requests
  end
end
