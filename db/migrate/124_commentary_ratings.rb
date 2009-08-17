class CommentaryRatings < ActiveRecord::Migration
  def self.up
    create_table :commentary_ratings do |t|
      t.column :user_id, :integer
      t.column :commentary_id, :integer
      t.column :rating, :integer
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
  end

  def self.down
    drop_table :commentary_ratings
  end
end
