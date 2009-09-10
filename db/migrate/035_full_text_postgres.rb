class FullTextPostgres < ActiveRecord::Migration
  def self.up

    execute "ALTER TABLE people ADD COLUMN fti_names tsvector;"
    execute "ALTER TABLE committees ADD COLUMN fti_names tsvector;"
    execute "ALTER TABLE bill_titles ADD COLUMN fti_titles tsvector;"
    execute "UPDATE people SET fti_names=to_tsvector('default', coalesce(name,'') ||' '|| coalesce(firstname, '') ||' '|| coalesce(lastname, ''));"
    execute "CREATE INDEX people_fti_names_index ON people USING gist(fti_names);"
    execute "UPDATE committees SET fti_names=to_tsvector('default', coalesce(name,'') ||' '|| coalesce(subcommittee_name, '') ||' '|| coalesce(people_name, '') ||' '|| coalesce(people_subcommittee_name, '') ||' '|| coalesce(bill_name, '') ||' '|| coalesce(bill_subcommittee_name, ''));"
    execute "CREATE INDEX committees_fti_names_index ON committees USING gist(fti_names);"
    execute "UPDATE bill_titles SET fti_titles=to_tsvector('default', coalesce(title, ''));" 
    execute "CREATE INDEX bill_titles_fti_titles_index ON bill_titles USING gist(fti_titles);"
    #execute "VACUUM FULL ANALYZE;"
  end 

  def self.down
    remove_column :people, :fti_names
    remove_column :committees, :fti_names
    remove_column :bill_titles, :fti_titles
  end 
end
