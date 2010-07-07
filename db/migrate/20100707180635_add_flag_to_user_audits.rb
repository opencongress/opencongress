class AddFlagToUserAudits < ActiveRecord::Migration
  def self.up
    add_column :user_audits, :processed, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :user_audits, :processed
  end
end
