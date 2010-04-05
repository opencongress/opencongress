class AddUserPartnerMailing < ActiveRecord::Migration
  def self.up
    add_column :users, :partner_mailing, :boolean, :default => false
  end

  def self.down
    remove_column :users, :partner_mailing
  end
end
