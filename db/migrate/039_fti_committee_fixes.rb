class FtiCommitteeFixes < ActiveRecord::Migration
  def self.up
    execute "DROP TRIGGER committee_tsvectorupdate ON committees;"
    execute "UPDATE committees SET fti_names=to_tsvector('default', coalesce(name,'') ||' '|| coalesce(subcommittee_name, ''));"
    execute "CREATE TRIGGER committee_tsvectorupdate BEFORE UPDATE OR INSERT ON committees FOR EACH ROW EXECUTE PROCEDURE tsearch2(fti_names, name, subcommittee_name);"
    remove_column :committees, :people_name
    remove_column :committees, :people_subcommittee_name
    remove_column :committees, :bill_name
    remove_column :committees, :bill_subcommittee_name
  end

  def self.down
    execute "DROP TRIGGER committee_tsvectorupdate ON committees;"
    execute "UPDATE committees SET fti_names=to_tsvector('default', coalesce(name,'') ||' '|| coalesce(subcommittee_name, '') ||' '|| coalesce(people_name, '') ||' '|| coalesce(people_subcommittee_name, '') ||' '|| coalesce(bill_name, '') ||' '|| coalesce(bill_subcommittee_name, ''));"
    execute "CREATE TRIGGER committee_tsvectorupdate BEFORE UPDATE OR INSERT ON committees FOR EACH ROW EXECUTE PROCEDURE tsearch2(fti_names, name, subcommittee_name, people_name, people_subcommittee_name, bill_name, bill_subcommittee_name);"
    add_column :committees, :people_name
    add_column :committees, :people_subcommittee_name
    add_column :committees, :bill_name
    add_column :committees, :bill_subcommittee_name
  end
end
