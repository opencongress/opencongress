class CreateVideos < ActiveRecord::Migration
  def self.up
    create_table :videos do |t|
      t.integer :person_id
      t.integer :bill_id
      t.string :embed
      t.string :title
      t.string :source
      t.date :video_date
      t.text :description
      
      t.timestamps
    end
    
    add_index :videos, :person_id
    add_index :videos, :bill_id
    add_index :videos, :embed
  end

  def self.down
    drop_table :videos
  end
end
