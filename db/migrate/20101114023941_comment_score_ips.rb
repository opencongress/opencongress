class CommentScoreIps < ActiveRecord::Migration
  def self.up
    add_column :comment_scores, :ip_address, :string
    
    add_index :comment_scores, [:comment_id, :ip_address]
  end

  def self.down
    remove_index :comment_scores, [:comment_id, :ip_address]
    remove_column :comment_scores, :ip_address
  end
end
