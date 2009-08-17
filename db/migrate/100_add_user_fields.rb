class AddUserFields < ActiveRecord::Migration
  def self.up
      add_column :users, :email,                     :string
      add_column :users, :crypted_password,          :string, :limit => 40
      add_column :users, :salt,                      :string, :limit => 40
      add_column :users, :created_at,                :datetime
      add_column :users, :updated_at,                :datetime
      add_column :users, :remember_token,            :string
      add_column :users, :remember_token_expires_at, :datetime
      add_column :users, :role_id,                   :integer
      add_column :users, :status,                    :integer
      add_column :users, :last_login,                :datetime
      add_column :users, :location,                  :string, :default => ""
      add_column :users, :show_email,                :boolean, :default => false
      add_column :users, :show_homepage,     :boolean, :default => false
      add_column :users, :homepage,                  :string, :default => ""
      add_column :users, :subscribed,                :boolean, :default => false
      add_column :users, :activation_code, :string, :limit => 40
      add_column :users, :activated_at, :datetime
      add_column :users, :password_reset_code, :string, :limit => 40
      add_column :users, :zipcode, :string
      add_column :users, :mailing, :boolean, :default => false
      add_column :users, :accept_terms, :boolean
      add_column :users, :about, :text, :default => ""
      execute "update users set created_at=NOW();"
      execute "update users set activated_at=NOW();"
      execute "update users set crypted_password='TEMPPASSKTHX';"
      execute "update users set accept_terms = true;"
  end

  def self.down
     remove_column :users, :email
     remove_column :users, :crypted_password
     remove_column :users, :salt
     remove_column :users, :created_at
     remove_column :users, :updated_at
     remove_column :users, :remember_token
     remove_column :users, :remember_token_expires_at
     remove_column :users, :role_id
     remove_column :users, :status
     remove_column :users, :last_login
     remove_column :users, :location
     remove_column :users, :show_email
     remove_column :users, :show_homepage
     remove_column :users, :homepage
     remove_column :users, :subscribed
     remove_column :users, :activation_code
     remove_column :users, :activated_at
     remove_column :users, :password_reset_code
     remove_column :users, :zipcode
     remove_column :users, :mailing
     remove_column :users, :accept_terms
     remove_column :users, :about
  end
end
