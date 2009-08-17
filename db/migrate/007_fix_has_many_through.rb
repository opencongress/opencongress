class FixHasManyThrough < ActiveRecord::Migration
  def self.up
    #Whoops.  I got this wrong.  I didn't know about has_many
    #:through.  Sorry guys.

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

    drop_table :bills_cosponsors
    create_table "bills_cosponsors" do |t|
      t.column "person_id", :integer
      t.column "bill_id", :integer
    end
    
  end

  def self.down
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

    drop_table :bills_cosponsors
    create_table "bills_cosponsors", :id => false do |t|
      t.column "person_id", :integer
      t.column "bill_id", :integer
    end

  end
end
