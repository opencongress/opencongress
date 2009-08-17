class AddDateToReports < ActiveRecord::Migration
  def self.up
    add_column :committee_reports, :reported_at, :datetime
    add_column :committee_reports, :created_at, :datetime
    #AddDateToReports.new.parse
  end

  def self.down
    remove_column :committee_reports, :reported_at
    remove_column :committee_reports, :created_at
  end
end
