class CreateSidebars < ActiveRecord::Migration
  def self.up
    create_table :sidebars do |t|
      t.column "page", :string
      t.column "class_type", :string
      t.column "title", :string
      t.column "description", :text
      t.column "updated_at", :timestamp
    end

    create_table :sidebar_items do |t|
      t.column "sidebar_id", :integer
      t.column "bill_id", :integer
      t.column "person_id", :integer
      t.column "committee_id", :integer
      t.column "subject_id", :integer
      t.column "description", :text
      t.column "rank", :integer
      t.column "updated_at", :timestamp
    end

   end

  def self.down
    drop_table :sidebars
    drop_table :sidebar_items
  end
end