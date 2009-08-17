class AlterBillVotesSupport < ActiveRecord::Migration
  def self.up
    drop_table :bill_votes
    create_table :bill_votes do |t|
      # t.column :name, :string
       t.column :bill_id, :integer
       t.column :user_id, :integer
       t.column :support, :smallint, :default => 0
       t.column :created_at, :datetime
       t.column :updated_at, :datetime
    end
    add_index :bill_votes, :created_at
    add_index :bill_votes, :bill_id

  end

  def self.down

  end
end
