class CreateCommitteeMeetingsBills < ActiveRecord::Migration
  def self.up
    create_table :committee_meetings_bills do |t|
      t.column :committee_meeting_id, :integer
      t.column :bill_id, :integer
    end
  end

  def self.down
    drop_table :committee_meetings_bills
  end
end
