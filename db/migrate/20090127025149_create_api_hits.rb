class CreateApiHits < ActiveRecord::Migration
  def self.up
    create_table :api_hits do |t|
      t.string :action
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :api_hits
  end
end
