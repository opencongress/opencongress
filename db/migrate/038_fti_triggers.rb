class FtiTriggers < ActiveRecord::Migration
  def self.up
    execute "CREATE TRIGGER people_tsvectorupdate BEFORE UPDATE OR INSERT ON people FOR EACH ROW EXECUTE PROCEDURE tsearch2(fti_names, name, firstname, lastname);"
    execute "CREATE TRIGGER bill_titles_tsvectorupdate BEFORE UPDATE OR INSERT ON bill_titles FOR EACH ROW EXECUTE PROCEDURE tsearch2(fti_titles, title);"
    execute "CREATE TRIGGER committee_tsvectorupdate BEFORE UPDATE OR INSERT ON committees FOR EACH ROW EXECUTE PROCEDURE tsearch2(fti_names, name, subcommittee_name, people_name, people_subcommittee_name, bill_name, bill_subcommittee_name);"
    execute "VACUUM FULL ANALYZE;"

  end

  def self.down
    execute "DROP TRIGGER people_tsvectorupdate on people"
    execute "DROP TRIGGER bill_titles_tsvectorupdate on bill_titles"
    execute "DROP TRIGGER committee_tsvectorupdate on committees"
  end
end
