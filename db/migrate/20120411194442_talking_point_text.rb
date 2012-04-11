class TalkingPointText < ActiveRecord::Migration
  def self.up
    change_column :talking_points, :talking_point, :text
  end

  def self.down
    change_column :talking_points, :talking_point, :string
  end
end
