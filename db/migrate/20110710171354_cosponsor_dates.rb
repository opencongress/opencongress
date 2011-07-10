class CosponsorDates < ActiveRecord::Migration
  def self.up
    add_column :bills_cosponsors, :date_added, :date
    add_column :bills_cosponsors, :date_withdrawn, :date
  end

  def self.down
    remove_column :bills_cosponsors, :date_added
    remove_column :bills_cosponsors, :date_withdrawn
  end
end
