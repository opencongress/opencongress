class CreatePersonApprovals < ActiveRecord::Migration
  def self.up
    create_table :person_approvals do |t|
      t.column :user_id, :integer
      t.column :rating, :integer
      t.column :person_id, :integer
      t.column :created_at, :datetime
      t.column :update_at, :datetime
    end
  end

  def self.down
    drop_table :person_approvals
  end
end
