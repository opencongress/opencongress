class AddUserAudits < ActiveRecord::Migration
  def self.up
    create_table :user_audits do |t|
      t.integer :user_id
      t.string :action, :email, :email_was, :full_name, :district, :zipcode, :state
      t.timestamp :created_at
    end
  end

  def self.down
    drop_table :user_audits
  end
end
