class ZipcodeDb < ActiveRecord::Migration
  def self.up
    execute 'CREATE TABLE zipcode_districts 
             ("zip5" char(5), "zip4" char(4), "state" char(2), "district" smallint, PRIMARY KEY(zip5,zip4))'
    
    # some indices we need
    add_index :bills, :sponsor_id
    
    execute "CREATE INDEX bill_titles_upper_title_index ON bill_titles (UPPER(title));"
  end

  
  def self.down
    drop_table :zipcode_districts

    remove_index :bills, :sponsor_id
    
    execute "DROP INDEX bill_titles_upper_title_index"
  end
end