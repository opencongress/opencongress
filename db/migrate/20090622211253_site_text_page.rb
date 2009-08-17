class SiteTextPage < ActiveRecord::Migration
  def self.up
    create_table :site_text_pages do |t|      
      t.string :page_params
      t.string :title_tags
      t.text :meta_description
      t.string :meta_keywords
      t.text :title_desc
      t.text :page_text_editable_type
      t.integer :page_text_editable_id
    end
  end

  def self.down
    drop_table :site_text_pages
  end
end
