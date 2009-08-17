class CreatePageViews < ActiveRecord::Migration
  def self.up
    create_table :page_views do |t|
      t.column :type, :string
      t.column :bill_id, :integer
      t.column :subject_id, :integer
      t.column :person_id, :integer
      t.column :created_at, :datetime
    end
    add_index :page_views, [:created_at, :type, :bill_id, :subject_id, :person_id]
  end

  def self.down
    drop_table :page_views
  end
end
