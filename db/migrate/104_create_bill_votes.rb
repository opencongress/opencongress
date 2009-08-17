class CreateBillVotes < ActiveRecord::Migration
  def self.up
    create_table :bill_votes do |t|
      # t.column :name, :string
       t.column :bill_id, :integer
       t.column :user_id, :integer
       t.column :support, :boolean, :default => false
       t.column :created_at, :datetime
       t.column :updated_at, :datetime
    end
  end

  def self.down
    drop_table :bill_votes
  end
end
