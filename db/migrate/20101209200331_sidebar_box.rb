class SidebarBox < ActiveRecord::Migration
  def self.up
    # remove some old deprecated tables
    drop_table :sidebars
    drop_table :sidebar_items
    
    create_table :sidebar_boxes do |t|
      t.string :image_url
      t.text :box_html
      t.integer :sidebarable_id
      t.string :sidebarable_type
    end
    
    add_index :sidebar_boxes, [:sidebarable_id, :sidebarable_type], :name => 'sidebarable_poly_idx'
  end

  def self.down
    drop_table :sidebar_boxes
  end
end
