class FixSchema < ActiveRecord::Migration
  def self.up
    remove_column :bills, :title
    drop_table :bill_actions
    add_column :actions, :amendment_id, :integer
  end

  def self.down
    add_column :bills, :title, :string
    create_table "bill_actions" do |t|
      t.column "bill_id", :integer
      t.column "action_id", :integer
    end
    remove_column :actions, :amendment_id
  end
end
