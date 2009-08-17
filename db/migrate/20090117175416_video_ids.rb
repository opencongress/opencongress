class VideoIds < ActiveRecord::Migration
  def self.up
    add_column :people, :metavid_id, :string
    add_column :people, :youtube_id, :string
    
    add_column :videos, :description, :text  
    add_column :videos, :url, :string
    add_column :videos, :length, :integer
    add_index  :videos, :url

    change_column :videos, :embed, :text
  end

  def self.down
    remove_column :people, :metavid_id
    remove_column :people, :youtube_id
    
    remove_column :videos, :description
    remove_column :videos, :url
    remove_column :videos, :length
    
    change_column :videos, :embed, :string
  end
end
