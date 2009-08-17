class GpoBilltextTimestamps < ActiveRecord::Migration
  def self.up
    create_table :gpo_billtext_timestamps do |t|
      t.column :session, :integer
      t.column :bill_type, :string
      t.column :number, :integer
      t.column :version, :string
      t.column :created_at, :timestamp
    end 
    
  end

  def self.down
    drop_table :gpo_billtext_timestamps
  end
end
