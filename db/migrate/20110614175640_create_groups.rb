class CreateGroups < ActiveRecord::Migration
  def self.up
    create_table :groups do |t|
      t.integer :user_id
      t.string :name
      t.text :description
      t.string :join_type
      t.string :invite_type
      t.string :post_type
      t.string :website
      t.integer :pvs_category_id

      t.string :group_image_file_name
      t.string :group_image_content_type
      t.integer :group_image_file_size
      t.datetime :group_image_updated_at

      t.timestamps
    end

    create_table :group_members do |t|
      t.integer :group_id
      t.integer :user_id
      t.string :status
      
      t.timestamps
    end

    create_table :group_invites do |t|
      t.integer :group_id
      t.integer :user_id
      t.string :email
      t.string :key
      
      t.timestamps
    end
    
    
    create_table :group_bill_positions do |t|
      t.integer :group_id
      t.integer :bill_id
      t.string :position
      t.string :comment
      t.string :permalink
       
      t.timestamps
    end
    
    add_column :political_notebooks, :group_id, :integer
    add_index :political_notebooks, :group_id
    
    add_column :notebook_items, :file_file_name, :string
    add_column :notebook_items, :file_content_type, :string
    add_column :notebook_items, :file_file_size, :integer
    add_column :notebook_items, :file_updated_at, :datetime

    add_column :notebook_items, :group_user_id, :integer
    
    ## join all users to two default groups
    admin_user = User.find_by_login('aross')
    State.all[0..3].each do |s|
      g = Group.new
      g.name = "OpenCongress #{s.name} Group"
      g.description = "Default group for users in #{s.name}"
      g.join_type = 'INVITE_ONLY'
      g.invite_type = 'MODERATOR'
      g.user = admin_user
      g.save
      
      users = User.find_by_sql(['select distinct users.id, users.login from users where state_cache like ?;', "%#{s.abbreviation}%"])
      users.each do |u|
        g.group_members.create(:user_id => u.id, :status => 'MEMBER')
      end
      
      g.save
    end
  end

  def self.down
    drop_table :groups
    drop_table :group_members
    drop_table :group_invites
    drop_table :group_bill_positions
    
    remove_column :political_notebooks, :group_id
    
    remove_column :notebook_items, :file_file_name
    remove_column :notebook_items, :file_content_type
    remove_column :notebook_items, :file_file_size
    remove_column :notebook_items, :file_updated_at
    
    # remove_column :notebook_items, :group_user_id
    
  end
end
