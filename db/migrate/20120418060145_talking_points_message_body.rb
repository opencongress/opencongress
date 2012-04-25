class TalkingPointsMessageBody < ActiveRecord::Migration
  def self.up
    add_column :talking_points, :include_in_message_body, :boolean, :default => false
    
    execute "UPDATE talking_points SET include_in_message_body='f'"
  end

  def self.down
    remove_column :talking_points, :include_in_message_body
  end
end
