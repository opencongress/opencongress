class RenameBillCommentaries < ActiveRecord::Migration
  def self.up
    add_column :bill_commentaries, :person_id, :integer
    rename_table :bill_commentaries, :commentaries
  end

  def self.down
    remove_column :commentaries, :person_id
    rename_table :commentaries, :bill_commentaries
  end
end
