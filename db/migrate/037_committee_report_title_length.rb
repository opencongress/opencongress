class CommitteeReportTitleLength < ActiveRecord::Migration
  def self.up
    remove_column :committee_reports, :title
    add_column :committee_reports, :title, :text
  end

  def self.down
    remove_column :committee_reports, :title
    add_column :committee_reports, :title, :string
  end
end
