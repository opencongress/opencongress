class AddFulltextIndeces < ActiveRecord::Migration
  def self.up
    if false
      execute "ALTER TABLE bills ENGINE = MYISAM" 
      execute "ALTER TABLE bill_titles ENGINE = MYISAM" 
      execute "ALTER TABLE committees ENGINE = MYISAM"
      execute "ALTER TABLE people ENGINE = MYISAM"
      
      execute "ALTER TABLE bills ADD FULLTEXT(summary)"
      execute "ALTER TABLE bill_titles ADD FULLTEXT(title)"
      execute "ALTER TABLE committees ADD FULLTEXT(name, subcommittee_name)"
      execute "ALTER TABLE people ADD FULLTEXT(firstname, lastname, nickname, name)"
    end
  end
  
  def self.down
    if false
      execute "DROP INDEX summary ON bills"
      execute "DROP INDEX title ON bill_titles"
      execute "DROP INDEX name ON committees"
      execute "DROP INDEX firstname ON people"

      execute "ALTER TABLE bills ENGINE = INNODB" 
      execute "ALTER TABLE bill_titles ENGINE = INNODB" 
      execute "ALTER TABLE committees ENGINE = INNODB"
      execute "ALTER TABLE people ENGINE = INNODB"
    end
  end
end
