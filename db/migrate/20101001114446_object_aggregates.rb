class ObjectAggregates < ActiveRecord::Migration
  def self.up    
    create_table :object_aggregates do |t|
      t.string :aggregatable_type
      t.integer :aggregatable_id
      t.date :date
      t.integer :page_views_count, :comments_count, :blog_articles_count, :news_articles_count, :bookmarks_count, :votes_support, :votes_oppose, :default => 0
    end
    add_index :object_aggregates, [:aggregatable_type, :aggregatable_id], :name => 'aggregatable_poly_idx'
    add_index :object_aggregates, [:date, :aggregatable_type], :name => 'aggregatable_date_type_idx'
    
    create_table :bill_referrers do |t|
      t.integer :bill_id
      t.string :url
      t.timestamp :created_at
    end    
    add_index :bill_referrers, :bill_id
    add_index :bill_referrers, :url

    execute "CREATE OR REPLACE FUNCTION aggregate_increment()
                RETURNS trigger AS '
                DECLARE
                    object_type varchar;
                    object_id integer;
                    column_name varchar;
                    agg_date date;
                    
                    entry object_aggregates%ROWTYPE;

                BEGIN
                  IF (TG_TABLE_NAME = ''comments'') THEN
                    object_type := NEW.commentable_type;
                    object_id := NEW.commentable_id;
                    column_name := ''comments_count'';
                    agg_date := NEW.created_at;
                  ELSIF (TG_TABLE_NAME = ''bookmarks'') THEN
                      object_type := NEW.bookmarkable_type;
                      object_id := NEW.bookmarkable_id;
                      column_name := ''bookmarks_count'';
                      agg_date := NEW.created_at;
                  ELSIF (TG_TABLE_NAME = ''bill_votes'') THEN
                      object_type := ''Bill'';
                      object_id := NEW.bill_id;
                      IF (NEW.support = 0) THEN
                        column_name := ''votes_support'';
                      ELSE 
                        column_name := ''votes_oppose'';
                      END IF;
                      agg_date := NEW.updated_at;
                  ELSIF (TG_TABLE_NAME = ''commentaries'') THEN
                      IF (NEW.is_ok = ''t'') THEN
                        object_type := NEW.commentariable_type;
                        object_id := NEW.commentariable_id;
                        IF (NEW.is_news = ''t'') THEN
                          column_name := ''news_articles_count'';
                        ELSE 
                          column_name := ''blog_articles_count'';
                        END IF;
                        agg_date := NEW.date;
                      END IF;
                  END IF;
              
                
                  SELECT * INTO entry FROM object_aggregates WHERE aggregatable_type = object_type AND aggregatable_id = object_id AND date = agg_date::date;
     
                  IF FOUND THEN
                    EXECUTE ''UPDATE object_aggregates SET '' || column_name || '' = '' || column_name || '' + 1 WHERE aggregatable_type = '''''' || object_type || '''''' AND aggregatable_id = '' || object_id || '' AND date = '''''' || agg_date || '''''''';
                  ELSE
                    EXECUTE ''INSERT INTO object_aggregates (aggregatable_type, aggregatable_id, date, '' || column_name || '') VALUES ('''''' || object_type || '''''', '' ||  object_id || '', '''''' || agg_date || '''''', 1)'';
                  END IF;
                  
                  RETURN NULL;
                END;
            '
            LANGUAGE plpgsql;"
            
     execute "CREATE TRIGGER aggregate_comment_trigger BEFORE INSERT ON comments FOR EACH ROW EXECUTE PROCEDURE aggregate_increment();"
     execute "CREATE TRIGGER aggregate_bookmark_trigger BEFORE INSERT ON bookmarks FOR EACH ROW EXECUTE PROCEDURE aggregate_increment();"
     execute "CREATE TRIGGER aggregate_bill_votes_trigger BEFORE INSERT ON bill_votes FOR EACH ROW EXECUTE PROCEDURE aggregate_increment();"
     execute "CREATE TRIGGER aggregate_commentaries_trigger BEFORE INSERT ON commentaries FOR EACH ROW EXECUTE PROCEDURE aggregate_increment();"

     execute "INSERT INTO object_aggregates (aggregatable_type, aggregatable_id, date, page_views_count)  
                SELECT viewable_type as aggregatable_type, viewable_id as aggregatable_id, created_at::date as date, 
                       count(id) as page_views_count 
                FROM page_views GROUP BY viewable_type, viewable_id, created_at::date;"

     # the following views aren't used in the code          
     execute "DROP VIEW list_representatives"
     execute "DROP VIEW list_senators"

     drop_table :page_views
  end

  def self.down
    drop_table :object_aggregates
    
    execute "DROP TRIGGER aggregate_comment_trigger ON comments"
    execute "DROP TRIGGER aggregate_bookmark_trigger ON bookmarks"
    execute "DROP TRIGGER aggregate_bill_votes_trigger ON bill_votes"
    execute "DROP TRIGGER aggregate_commentaries_trigger ON commentaries"
    execute "DROP FUNCTION aggregate_increment()"
  end
end
