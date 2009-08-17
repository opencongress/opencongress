class CreateComparisons < ActiveRecord::Migration
  def self.up
    create_table :comparisons do |t|
      t.string :type
      t.integer :congress
      t.string :chamber
      t.integer :average_value
      t.timestamps
    end
  end

  def self.down
    drop_table :comparisons
  end
end
