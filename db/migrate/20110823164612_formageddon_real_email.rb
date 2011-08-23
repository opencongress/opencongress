class FormageddonRealEmail < ActiveRecord::Migration
  def self.up
    add_column :formageddon_forms, :use_real_email_address, :boolean, :default => false
    
    execute "UPDATE formageddon_forms SET use_real_email_address='f'"
  end

  def self.down
    remove_column :formageddon_forms, :use_real_email_address
  end
end
