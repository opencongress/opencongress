class CreateWikiLinks < ActiveRecord::Migration
  def self.up
    create_table :wiki_links do |t|
      t.string :wikiable_type
      t.integer :wikiable_id
      t.string :name
      t.string :oc_link

      t.timestamps
    end
  end

  def self.down
    drop_table :wiki_links
  end
end
