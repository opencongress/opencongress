class CreatePosts < ActiveRecord::Migration
  def self.up
    create_table :posts, :force => true do |t|
      t.column :name, :string
      t.column :reply_counter, :integer
      t.column :posted_at, :datetime
    end
  end

  def self.down
    drop_table :posts
  end
end
