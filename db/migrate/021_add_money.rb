class AddMoney < ActiveRecord::Migration
  def self.up
    # We also need to change the bill model to:
    #   have_many :sectors => :through :people_sectors
    #   have_many :people_sectors
    #   has_one :top_contributor

    # :people_sectors is populated from the MemsSector.txt OpenSecrets file.
    create_table :people_sectors, :id => false do |t|
      t.column "person_id", :integer
      t.column "sector_id", :string
      t.column "total", :integer
      t.column "revision_date", :datetime
    end
    # :sectors is populated from the MemsSector.txt OpenSecrets file.
    create_table :sectors do |t|
      t.column "name", :string
    end
    # :contributors is populated from the Mems_TopContrib.txt OpenSecrets file.
    create_table :contributors do |t|
      t.column "name", :string
    end
    # These fields are populated from the MemsTotRaised.txt OpenSecrets file.
    add_column :bills, :money_raised, :integer
    add_column :bills, :money_raised_at, :datetime
    # These fields are populated from the Mems_TopContrib.txt OpenSecrets file.
    add_column :bills, :top_contributor_id, :integer
    add_column :bills, :top_contribution, :integer
    add_column :bills, :top_contributor_at, :datetime
  end

  def self.down
    drop_table :people_sectors
    drop_table :sectors
    drop_table :contributors
    remove_column :bills, :money_raised
    remove_column :bills, :money_raised_at
    remove_column :bills, :top_contributor_id
    remove_column :bills, :top_contribution
    remove_column :bills, :top_contributor_at
  end
end
