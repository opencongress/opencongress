class PeopleNameFs < ActiveRecord::Migration
  def self.up
    execute "DROP TRIGGER people_tsvectorupdate ON people"
    execute "CREATE TRIGGER people_tsvectorupdate BEFORE UPDATE OR INSERT ON people FOR EACH ROW EXECUTE PROCEDURE tsearch2(fti_names, name, firstname, lastname, nickname, unaccented_name);"

    execute "UPDATE people SET fti_names=to_tsvector('english', coalesce(name, '')||' '|| coalesce(firstname, '')||' '|| coalesce(lastname, '')||' '|| coalesce(nickname, '')||' '|| coalesce(unaccented_name, ''));"
  end

  def self.down
    execute "DROP TRIGGER people_tsvectorupdate ON people"
    execute "CREATE TRIGGER people_tsvectorupdate BEFORE UPDATE OR INSERT ON people FOR EACH ROW EXECUTE PROCEDURE tsearch2(fti_names, firstname, lastname, nickname, unaccented_name);"
  end
end
