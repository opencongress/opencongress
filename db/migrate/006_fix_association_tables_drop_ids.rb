class FixAssociationTablesDropIds < ActiveRecord::Migration
  def self.up
    drop_table :committees_people
    create_table "committees_people", :id => false do |t|
      t.column "committee_id", :integer
      t.column "person_id", :integer
    end
    drop_table :bills_committees
    create_table "bills_committees", :id => false do |t|
      t.column "bill_id", :integer
      t.column "committee_id", :integer
      t.column "activity", :string
    end
  end

  def self.down
    drop_table :committees_people
    create_table "committees_people" do |t|
      t.column "committee_id", :integer
      t.column "person_id", :integer
    end
    drop_table :bills_committees
    create_table "bills_committees" do |t|
      t.column "bill_id", :integer
      t.column "committee_id", :integer
      t.column "activity", :string
    end
  end
end

