class CreateUserWarnings < ActiveRecord::Migration
  def self.up
    create_table :user_warnings do |t|
      t.integer :user_id
      t.text :warning_message
      t.integer :warned_by

      t.timestamps
    end
  end

  def self.down
    drop_table :user_warnings
  end
end
