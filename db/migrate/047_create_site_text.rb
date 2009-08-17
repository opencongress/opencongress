class CreateSiteText < ActiveRecord::Migration
  def self.up
    create_table :site_texts do |t|
      t.column "text_type", :string
      t.column "text", :text
      t.column "updated_at", :timestamp
    end
   end

  def self.down
    drop_table :site_text
  end
end