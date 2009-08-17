class UpcomingBills < ActiveRecord::Migration
  def self.up
    create_table :upcoming_bills do |t|
      t.column :title, :text      
      t.column :summary, :text
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
    
    execute "ALTER TABLE upcoming_bills ADD COLUMN fti_names tsvector;"
    execute "CREATE INDEX upcoming_bill_fti_names_index ON upcoming_bills USING gist(fti_names);"
    execute "UPDATE upcoming_bills SET fti_names=to_tsvector('default', coalesce(title,'') ||' '|| coalesce(summary, ''));"
    execute "CREATE TRIGGER upcoming_bill_tsvectorupdate BEFORE UPDATE OR INSERT ON upcoming_bills FOR EACH ROW EXECUTE PROCEDURE tsearch2(fti_names, title, summary);"

    add_column :commentaries, :upcoming_bill_id, :integer
    add_index :commentaries, :upcoming_bill_id
    
    execute "ANALYZE commentaries"
  end

  def self.down
    drop_table :upcoming_bills
    remove_column :commentaries, :upcoming_bill_id
    remove_index :commentaries, :upcoming_bill_id
  end
end