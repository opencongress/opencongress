class ArticleTsearch < ActiveRecord::Migration
  def self.up
    execute "ALTER TABLE articles ADD COLUMN fti_names tsvector;"
    execute "CREATE INDEX articles_fti_names_index ON articles USING gist(fti_names);"
    execute "UPDATE articles SET fti_names=to_tsvector('default', coalesce(article,''));"
    execute "CREATE TRIGGER article_tsvectorupdate BEFORE UPDATE OR INSERT ON articles FOR EACH ROW EXECUTE PROCEDURE tsearch2(fti_names, article);" 
  end
  
  def self.down
    execute "DROP TRIGGER article_tsvectorupdate ON sectors;"
    execute "DROP INDEX articles_fti_names_index"
  end
end
