class FixCommitteeReport < ActiveRecord::Migration
  def self.up
    add_column :committee_reports, :congress, :integer
  end

  def self.down
    remove_column :committee_reports, :congress
  end
end
