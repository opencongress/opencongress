class CreateCommentScores < ActiveRecord::Migration
  def self.up
    create_table :comment_scores do |t|
      # t.column :name, :string
      t.column :user_id, :integer
      t.column :comment_id, :integer
      t.column :score, :integer
      t.column :created_at, :datetime
    end
  end

  def self.down
    drop_table :comment_scores
  end
end
