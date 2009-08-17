class CreateCommitteeMeetings < ActiveRecord::Migration
  def self.up
    create_table :committee_meetings do |t|
      t.column :subject, :text
      t.column :meeting_at, :datetime
      t.column :committee_id, :integer
      t.column :where, :string
    end
  end

  def self.down
    drop_table :committee_meetings
  end
end
