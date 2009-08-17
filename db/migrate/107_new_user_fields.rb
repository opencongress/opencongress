class NewUserFields < ActiveRecord::Migration
  def self.up
    add_column :users, :chat_aim, :string, :default => ""
    add_column :users, :chat_yahoo, :string, :default => ""
    add_column :users, :chat_msn, :string, :default => ""
    add_column :users, :chat_icq, :string, :default => ""
    add_column :users, :chat_gtalk, :string, :default => ""
    add_column :users, :show_aim, :boolean, :default => false 
    add_column :users, :show_full_name, :boolean, :default => false
    add_column :users, :default_filter, :integer, :default => 5
  end

  def self.down
    remove_column :users, :chat_aim
    remove_column :users, :chat_yahoo
    remove_column :users, :chat_msn
    remove_column :users, :chat_icq
    remove_column :users, :chat_gtalk
    remove_column :users, :show_aim
    remove_column :users, :show_full_name
    remove_column :users, :default_filter

  end
end
