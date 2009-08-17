class IndicesSubjectBillsubject < ActiveRecord::Migration
  def self.up
    add_index :bill_subjects, [:bill_id, :subject_id]
    add_index :subjects, :term
  end

  def self.down
    remove_index :bill_subjects, [:bill_id, :subject_id]
    remove_index :subjects, :term
  end
end
