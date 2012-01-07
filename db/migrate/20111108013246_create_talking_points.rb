class CreateTalkingPoints < ActiveRecord::Migration
  def self.up
    create_table :talking_points do |t|
      t.integer :talking_pointable_id
      t.string :talking_pointable_type
      t.string :talking_point

      t.timestamps
    end
  end

  def self.down
    drop_table :talking_points
  end
end
