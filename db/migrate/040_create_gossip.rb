class CreateGossip < ActiveRecord::Migration

  def self.up
    create_table :gossip do |t|
      t.column :name, :string
      t.column :title, :string
      t.column :email, :string
      t.column :link, :string
      t.column :tip, :text
      t.column :frontpage, :boolean, :default => false
      t.column :approved, :boolean, :default => false
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
  end

  def self.down
    drop_table :gossip
  end
end
