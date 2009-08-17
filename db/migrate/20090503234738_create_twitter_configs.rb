class CreateTwitterConfigs < ActiveRecord::Migration
  def self.up
    create_table :twitter_configs do |t|
      t.integer :user_id
      t.string :secret
      t.string :token
      t.boolean :tracking
      t.boolean :bill_votes
      t.boolean :person_approvals
      t.boolean :new_notebook_items
      t.boolean :logins

      t.timestamps
    end
  end

  def self.down
    drop_table :twitter_configs
  end
end
