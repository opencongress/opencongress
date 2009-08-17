class CreateBillBattles < ActiveRecord::Migration
  def self.up
    create_table :bill_battles do |t|
      t.column :first_bill_id, :integer
      t.column :second_bill_id, :integer
      t.column :first_score, :integer
      t.column :second_score, :integer
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      t.column :created_by, :integer
      t.column :active, :boolean
      t.column :run_date, :datetime
    end
  end

  def self.down
    drop_table :bill_battles
  end
end
