class CreateWatchDogs < ActiveRecord::Migration
  def self.up
    create_table :watch_dogs do |t|
      t.integer :district_id
      t.integer :user_id
      t.boolean :is_active

      t.timestamps
    end
  end

  def self.down
    drop_table :watch_dogs
  end
end
