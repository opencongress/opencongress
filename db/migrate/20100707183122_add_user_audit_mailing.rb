class AddUserAuditMailing < ActiveRecord::Migration
  def self.up
    add_column :user_audits, :mailing, :boolean, :default => false, :null => false
    # execute "update user_audits a set mailing = (select mailing from users where id = a.user_id)"
    remove_column :user_audits, :action
  end

  def self.down
    remove_column :user_audits, :mailing
    add_column :user_audits, :action, :string
  end
end