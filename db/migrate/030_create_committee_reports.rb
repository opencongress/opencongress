class CreateCommitteeReports < ActiveRecord::Migration
  def self.up
    create_table :committee_reports do |t|
      t.column :name, :string
      t.column :index, :integer
      t.column :number, :integer
      t.column :title, :string
      t.column :kind, :string
      t.column :person_id, :integer
      t.column :bill_id, :integer
      t.column :committee_id, :integer
    end
  end

  def self.down
    drop_table :committee_reports
  end
end
