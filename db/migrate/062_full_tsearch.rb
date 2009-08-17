class FullTsearch < ActiveRecord::Migration
  def self.up
    execute "DROP TRIGGER people_tsvectorupdate ON people;"
    execute "UPDATE people SET fti_names=to_tsvector('default', coalesce(firstname, '')||' '|| coalesce(lastname, '')||' '|| coalesce(nickname, ''));"
    execute "CREATE TRIGGER people_tsvectorupdate BEFORE UPDATE OR INSERT ON people FOR EACH ROW EXECUTE PROCEDURE tsearch2(fti_names, firstname, lastname, nickname);"

    execute "ALTER TABLE subjects ADD COLUMN fti_names tsvector;"
    execute "CREATE INDEX subject_fti_names_index ON subjects USING gist(fti_names);"
    execute "UPDATE subjects SET fti_names=to_tsvector('default', coalesce(term,''));"
    execute "CREATE TRIGGER subject_tsvectorupdate BEFORE UPDATE OR INSERT ON subjects FOR EACH ROW EXECUTE PROCEDURE tsearch2(fti_names, term);"

    execute "ALTER TABLE sectors ADD COLUMN fti_names tsvector;"
    execute "CREATE INDEX sector_fti_names_index ON sectors USING gist(fti_names);"
    execute "UPDATE sectors SET fti_names=to_tsvector('default', coalesce(name,''));"
    execute "CREATE TRIGGER sector_tsvectorupdate BEFORE UPDATE OR INSERT ON sectors FOR EACH ROW EXECUTE PROCEDURE tsearch2(fti_names, name);"

    add_index :commentaries, [ :bill_id, :person_id, :status, :commentary_type, :date ]
    
    execute "ALTER TABLE commentaries ADD COLUMN fti_names tsvector;"
    execute "CREATE INDEX commentary_fti_names_index ON commentaries USING gist(fti_names);"
    execute "UPDATE commentaries SET fti_names=to_tsvector('default', coalesce(title,'') ||' '|| coalesce(excerpt, '')||' '|| coalesce(source, ''));"
    execute "CREATE TRIGGER commentary_tsvectorupdate BEFORE UPDATE OR INSERT ON commentaries FOR EACH ROW EXECUTE PROCEDURE tsearch2(fti_names, title, excerpt, source);"

    create_table :bill_fulltext, :id => false, :force => true do |t|
      t.column "bill_id", :integer
      t.column "fulltext", :text
    end
        
    execute "ALTER TABLE bill_fulltext ADD COLUMN fti_names tsvector;"
    execute "CREATE INDEX bill_fti_names_index ON bill_fulltext USING gist(fti_names);"
    execute "CREATE TRIGGER bill_tsvectorupdate BEFORE UPDATE OR INSERT ON bill_fulltext FOR EACH ROW EXECUTE PROCEDURE tsearch2(fti_names, fulltext);"
    
    Bill.find(:all).each do |b|
      titles = quote_string("#{b.all_titles_string} #{b.plain_language_summary}")
      execute "INSERT INTO bill_fulltext (bill_id, fulltext) VALUES (#{b.id}, '#{titles}')"
    end
    
    add_index :roll_call_votes, :roll_call_id
    
    execute "VACUUM FULL ANALYZE"
  end

  def self.down
    execute "DROP TRIGGER subject_tsvectorupdate ON subjects;"
    execute "DROP INDEX subject_fti_names_index"
    remove_column :subjects, :fti_names

    execute "DROP TRIGGER sector_tsvectorupdate ON sectors;"
    execute "DROP INDEX sector_fti_names_index"
    remove_column :sectors, :fti_names

    execute "DROP TRIGGER commentary_tsvectorupdate ON commentaries;"
    execute "DROP INDEX commentary_fti_names_index"
    remove_column :commentaries, :fti_names

    remove_index :commentaries, [:bill_id]

    drop_table :bill_fulltext

    remove_column :bills, :titles_for_search
    
    remove_index :roll_call_votes, :roll_call_id
  end
end