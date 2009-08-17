class FixSchema2 < ActiveRecord::Migration
  def self.up
    rename_column :bills, :sponser_id, :sponsor_id
    remove_column :amendments, :sequence # Use table order instead
    rename_table :bills_cosponsers, :bills_cosponsors
    drop_table :people
    create_table "people" do |t| # from repstats/person.xml
      t.column "firstname", :string
      t.column "middlename", :string
      t.column "lastname", :string
      t.column "nickname", :string
      t.column "birthday", :date
      t.column "gender", :string, :limit => 1
      t.column "religon", :string
      t.column "url", :string
      t.column "party", :string
      t.column "osid", :string
      t.column "bioguideid", :string
      t.column "title", :string
      t.column "state", :string
      t.column "district", :string
      t.column "name", :string # NOT redundant
      t.column "email", :string
    end
  end

  def self.down
    rename_column :bills, :sponsor_id, :sponser_id
    add_column :amendments, :sequence, :integer
    rename_table :bill_cosponsors, :bill_cosponsers
  end
end
