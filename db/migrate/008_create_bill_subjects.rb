class CreateBillSubjects < ActiveRecord::Migration
  def self.up
    create_table :bill_subjects do |t|
      t.column "bill_id", :integer
      t.column "subject_id", :integer
    end
  end

  def self.down
    drop_table :bill_subjects
  end
end
