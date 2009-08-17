class BillText < ActiveRecord::Migration
  def self.up
    create_table :bill_text_versions do |t|
      t.column :bill_id, :integer 
      t.column :version, :string
      t.column :word_count, :integer, :default => 0
      t.column :previous_version, :string
      t.column :difference_size_chars, :integer, :default => 0
      t.column :percent_change, :integer, :default => 0
      t.column :total_changes, :integer, :default => 0
      t.column :file_timestamp, :datetime
    end 
    
    create_table :bill_text_nodes do |t|
      t.column :bill_text_version_id, :integer
      t.column :nid, :string
    end 
    
    add_index :bill_text_versions, :bill_id
    add_index :bill_text_nodes, :bill_text_version_id
    add_index :bill_text_nodes, :nid
  end
  
  def self.down
    drop_table :bill_text_versions
    drop_table :bill_text_nodes
  end
end
