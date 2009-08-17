class CreateRolls < ActiveRecord::Migration
  def self.up
    create_table :roll_calls do |t|
      t.column :number, :integer # corresponds to govtrack
      t.column :where, :string
      t.column :date, :datetime
      t.column :updated, :datetime
      t.column :roll_type, :string
      t.column :question, :text
      t.column :required, :string
      t.column :result, :string
      t.column :bill_id, :integer
      t.column :amendment_id, :integer
    end

    create_table :roll_call_votes do |t|
        t.column :vote, :char
        t.column :roll_call_id, :integer
        t.column :person_id, :integer
    end
  end

  def self.down
    drop_table :roll_calls
    drop_table :roll_call_votes
  end
end
