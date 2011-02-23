class CommentaryTriggerFix < ActiveRecord::Migration
  def self.up
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
                      ELSE
                        RETURN NULL;
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
  end

  def self.down
  end
end
