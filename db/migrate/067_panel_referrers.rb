class PanelReferrers < ActiveRecord::Migration
  def self.up
    create_table :panel_referrers do |t|
      t.column "referrer_url", :text, :null => false
      t.column "panel_type", :string      
      t.column "views", :integer, :default => 0      
      t.column "updated_at", :timestamp
    end
    
    add_index :panel_referrers, :referrer_url
    add_index :panel_referrers, :panel_type
  end
  
  def self.down
    drop_table :panel_referrers
  end
end