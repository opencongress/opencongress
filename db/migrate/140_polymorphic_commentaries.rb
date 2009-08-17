class PolymorphicCommentaries < ActiveRecord::Migration
  def self.up
    add_column :commentaries, :commentariable_id, :integer
    add_column :commentaries, :commentariable_type, :string
    
    execute "UPDATE commentaries SET commentariable_id=bill_id, commentariable_type='Bill' WHERE bill_id IS NOT NULL"
    execute "UPDATE commentaries SET commentariable_id=person_id, commentariable_type='Person' WHERE person_id IS NOT NULL"

    remove_column :commentaries, :bill_id
    remove_column :commentaries, :person_id
    remove_column :commentaries, :upcoming_bill_id
    
    add_index :commentaries, [:commentariable_id, :commentariable_type, :is_ok, :is_news]
    add_index :commentaries, [:commentariable_type, :date, :is_ok, :is_news]

    remove_index :commentaries, [:date, :is_ok, :is_news]
    
    execute "VACUUM ANALYZE commentaries"
  end
  
  def self.down
    add_column :commentaries, :bill_id, :integer
    add_column :commentaries, :person_id, :integer
    add_column :commentaries, :upcoming_bill_id, :integer
    
    execute "UPDATE commentaries SET bill_id=commentariable_id WHERE commentariable_type='Bill'"
    execute "UPDATE commentaries SET person_id=commentariable_id WHERE commentariable_type='Person'"
    execute "UPDATE commentaries SET upcoming_bill_id=commentariable_id WHERE commentariable_type='UpcomingBill'"
    
    remove_column :commentaries, :commentariable_id
    remove_column :commentaries, :commentariable_type
  end
end