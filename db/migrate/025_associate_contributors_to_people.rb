class AssociateContributorsToPeople < ActiveRecord::Migration
  #Associates money with people rather than with bills.

  def self.up
    remove_column :bills, :money_raised
    remove_column :bills, :money_raised_at
    remove_column :bills, :top_contributor_id
    remove_column :bills, :top_contribution
    remove_column :bills, :top_contributor_at
    add_column :people, :money_raised, :integer
    add_column :people, :money_raised_at, :datetime
    add_column :people, :top_contributor_id, :integer
    add_column :people, :top_contribution, :integer
    add_column :people, :top_contributor_at, :datetime

    drop_table :people_sectors
    create_table :people_sectors do |t|
      t.column "person_id", :integer
      t.column "sector_id", :string
      t.column "total", :integer
      t.column "revision_date", :datetime
    end
  end

  def self.down
    remove_column :people, :money_raised
    remove_column :people, :money_raised_at
    remove_column :people, :top_contributor_id
    remove_column :people, :top_contribution
    remove_column :people, :top_contributor_at
    add_column :bills, :money_raised, :integer
    add_column :bills, :money_raised_at, :datetime
    # These fields are populated from the Mems_TopContrib.txt OpenSecrets file.
    add_column :bills, :top_contributor_id, :integer
    add_column :bills, :top_contribution, :integer
    add_column :bills, :top_contributor_at, :datetime

    drop_table :people_sectors
    create_table :people_sectors, :id => false do |t|
      t.column "person_id", :integer
      t.column "sector_id", :string
      t.column "total", :integer
      t.column "revision_date", :datetime
    end
  end
end
