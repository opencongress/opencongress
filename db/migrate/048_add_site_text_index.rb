class AddSiteTextIndex < ActiveRecord::Migration
  def self.up
    add_index :site_texts, :text_type
  end

  def self.down
    remove_index :site_texts, :text_type
  end
end
    