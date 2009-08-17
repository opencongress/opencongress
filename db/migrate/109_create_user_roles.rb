class CreateUserRoles < ActiveRecord::Migration
  def self.up
    create_table :user_roles do |t|
      t.column :name, :string, :default => ""
      t.column :can_blog, :boolean, :default => false
      t.column :can_administer_users, :boolean, :default => false
      t.column :can_see_stats, :boolean, :default => false
      t.column :can_manage_text, :boolean, :default => false
      t.column :can_moderate_articles, :boolean, :default => false
      t.column :can_edit_blog_tags, :boolean, :default => false
    end
    remove_column :users, :role_id
    add_column :users, :user_role_id, :integer, :default => 0
    execute "insert into user_roles (id, name) values (0,'User');"
    execute "insert into user_roles (id, name, can_blog, can_edit_blog_tags) values (1,'Blogger',true,true);"
    execute "insert into user_roles (id, name, can_blog, can_administer_users, can_see_stats, can_manage_text, can_moderate_articles, can_edit_blog_tags) values (2,'Administrator',true,true,true,true,true,true);"
    execute "insert into user_roles (id, name, can_see_stats) values (3,'Stats Viewer', true);"
    execute "update users set user_role_id = 2 where login in ('d2d','donny','drm','admin','agp','aross');"
    execute "update users set user_role_id = 3 where login = 'Sunlight';"
    execute "update users set user_role_id = 0 where user_role_id is null;"
  end

  def self.down
    drop_table :user_roles
    remove_column :users, :user_role_id
    add_column :users, :role_id, :integer
  end
end
