class CreateGroups < ActiveRecord::Migration
  def self.up
    create_table :groups do |t|
      t.integer :user_id
      t.string :name
      t.text :description
      t.string :join_type
      t.string :invite_type
      t.string :post_type
      t.boolean :publicly_visible, :default => true
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
      t.boolean :receive_owner_emails, :default => true
      
      t.timestamps
    end

    add_index :group_members, :group_id
    add_index :group_members, :user_id
    
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
    admin_user = User.find_by_login('drm_testing')
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
    
    PvsCategory.all.each do |c|
      g = Group.new
      g.name = "The #{c.name} Group"
      g.description = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris vehicula, quam pretium volutpat pharetra, eros tellus scelerisque velit, eget auctor dolor justo ac purus. Vivamus id urna ac enim faucibus vestibulum. Phasellus pharetra adipiscing lobortis. Proin erat lorem, sagittis at lobortis non, interdum ac diam. Morbi eu neque non magna pretium facilisis ut a ligula. Nullam in metus sit amet nisi pharetra ultricies. In dapibus, neque in rhoncus aliquet, elit metus molestie tortor, quis porta enim elit sit amet lacus. Fusce sit amet sollicitudin urna. Maecenas elit nibh, condimentum ac egestas in, tristique at nunc. Sed varius, neque eget convallis dignissim, orci diam tristique sapien, ac rutrum dolor odio non sapien. Etiam auctor posuere dolor, et volutpat justo hendrerit ut."
      g.join_type = 'ANYONE'
      g.invite_type = 'ANYONE'
      g.user = admin_user
      g.pvs_category = c
      
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
    
    remove_column :notebook_items, :group_user_id
    
  end
end
