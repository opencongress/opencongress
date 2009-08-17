class CreateSearches < ActiveRecord::Migration
  def self.up
    create_table :searches do |t|
      t.column "search_text", :string
      t.column "created_at", :timestamp
    end
   end

  def self.down
    drop_table :searches
  end
end