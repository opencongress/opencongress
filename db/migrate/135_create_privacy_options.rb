class CreatePrivacyOptions < ActiveRecord::Migration
  def self.up
    create_table :privacy_options do |t|
      t.integer :my_full_name, :my_email, :my_last_login_date, :my_zip_code, :my_instant_messanger_names, :my_website, :my_location, :about_me, :my_actions, :my_tracked_items, :my_friends, :my_congressional_district, :default => 0
      t.integer :user_id
      t.timestamps
    end
    add_index :privacy_options, :user_id
    User.find(:all).each do |u|
      PrivacyOption.create({:user_id => u.id, 
                            :my_website => u.show_homepage ? 2 : 0, 
                            :my_instant_messanger_names => u.show_aim ? 2 : 0,
                            :my_full_name => u.show_full_name ? 2 : 0,
                            :my_tracked_items => 2,
                            :my_actions => 2})
    end
    add_column :users, :feed_key, :string
  end

  def self.down
    remove_index :privacy_options, :user_id
    drop_table :privacy_options
    remove_column :users, :feed_key
  end
end
