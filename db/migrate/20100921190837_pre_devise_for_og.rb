class PreDeviseForOg < ActiveRecord::Migration
  def self.up
    rename_column :users, :remember_token_expires_at, :remember_created_at
    add_column :users, :authentication_token, :string
  end

  def self.down
    rename_column :users, :remember_created_at, :remember_token_expires_at
    remove_column :users, :authentication_token
  end
end
