class BillRelationsId < ActiveRecord::Migration
  def self.up
    drop_table :bills_relations
    create_table "bills_relations", :force => true do |t|
      t.column "relation", :string
      t.column "bill_id", :integer
      t.column "related_bill_id", :integer
    end
  end

  def self.down
    drop_table :bills_relations
    create_table "bills_relations", :id => false, :force => true do |t|
      t.column "relation", :string
      t.column "bill_id", :integer
      t.column "related_bill_id", :integer
    end
  end
end
