class CreateUserMailingLists < ActiveRecord::Migration
  def self.up
    create_table :user_mailing_lists do |t|
      t.integer :user_id
      t.datetime :last_processed
      t.integer :status

      t.timestamps
    end
  end

  def self.down
    drop_table :user_mailing_lists
  end
end
