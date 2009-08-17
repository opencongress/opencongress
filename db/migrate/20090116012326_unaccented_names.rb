class UnaccentedNames < ActiveRecord::Migration
  def self.up
    add_column :people, :unaccented_name, :string
    
    execute "DROP TRIGGER people_tsvectorupdate ON people"
    execute "CREATE TRIGGER people_tsvectorupdate BEFORE UPDATE OR INSERT ON people FOR EACH ROW EXECUTE PROCEDURE tsearch2(fti_names, firstname, lastname, nickname, unaccented_name);"
  end

  def self.down
    remove_column :people, :unaccented_name

    execute "DROP TRIGGER people_tsvectorupdate ON people"
    execute "CREATE TRIGGER people_tsvectorupdate BEFORE UPDATE OR INSERT ON people FOR EACH ROW EXECUTE PROCEDURE tsearch2(fti_names, firstname, lastname, nickname);"
  end
end
