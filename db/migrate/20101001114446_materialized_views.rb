class MaterializedViews < ActiveRecord::Migration
  def self.up
    # execute "CREATE TABLE matviews (
    #           mv_name NAME NOT NULL PRIMARY KEY, 
    #           v_name NAME NOT NULL,
    #           last_refresh TIMESTAMP WITH TIME ZONE);"
    #           
    # execute "CREATE OR REPLACE FUNCTION create_matview(NAME, NAME)
    #            RETURNS VOID
    #            SECURITY DEFINER
    #            LANGUAGE plpgsql AS '
    #            DECLARE
    #                matview ALIAS FOR $1;
    #                view_name ALIAS FOR $2;
    #                entry matviews%ROWTYPE;
    #            BEGIN
    #                SELECT * INTO entry FROM matviews WHERE mv_name = matview;
    # 
    #                IF FOUND THEN
    #                    RAISE EXCEPTION ''Materialized view ''''%'''' already exists.'',
    #                      matview;
    #                END IF;
    # 
    #                EXECUTE ''REVOKE ALL ON '' || view_name || '' FROM PUBLIC''; 
    # 
    #                EXECUTE ''GRANT SELECT ON '' || view_name || '' TO PUBLIC'';
    # 
    #                EXECUTE ''CREATE TABLE '' || matview || '' AS SELECT * FROM '' || view_name;
    # 
    #                EXECUTE ''REVOKE ALL ON '' || matview || '' FROM PUBLIC'';
    # 
    #                EXECUTE ''GRANT SELECT ON '' || matview || '' TO PUBLIC'';
    # 
    #                INSERT INTO matviews (mv_name, v_name, last_refresh)
    #                  VALUES (matview, view_name, CURRENT_TIMESTAMP); 
    # 
    #                RETURN;
    #            END
    #            ';"
    #            
    # execute "CREATE OR REPLACE FUNCTION drop_matview(NAME) RETURNS VOID
    #             SECURITY DEFINER
    #             LANGUAGE plpgsql AS '
    #             DECLARE
    #                 matview ALIAS FOR $1;
    #                 entry matviews%ROWTYPE;
    #             BEGIN
    # 
    #                 SELECT * INTO entry FROM matviews WHERE mv_name = matview;
    # 
    #                 IF NOT FOUND THEN
    #                     RAISE EXCEPTION ''Materialized view % does not exist.'', matview;
    #                 END IF;
    # 
    #                 EXECUTE ''DROP TABLE '' || matview;
    #                 DELETE FROM matviews WHERE mv_name=matview;
    # 
    #                 RETURN;
    #             END
    #             ';"
    #             
    # execute "CREATE OR REPLACE FUNCTION refresh_matview(name) RETURNS VOID
    #              SECURITY DEFINER
    #              LANGUAGE plpgsql AS '
    #              DECLARE 
    #                  matview ALIAS FOR $1;
    #                  entry matviews%ROWTYPE;
    #              BEGIN
    # 
    #                  SELECT * INTO entry FROM matviews WHERE mv_name = matview;
    # 
    #                  IF NOT FOUND THEN
    #                      RAISE EXCEPTION ''Materialized view % does not exist.'', matview;
    #                 END IF;
    # 
    #                 EXECUTE ''DELETE FROM '' || matview;
    #                 EXECUTE ''INSERT INTO '' || matview
    #                     || '' SELECT * FROM '' || entry.v_name;
    # 
    #                 UPDATE matviews
    #                     SET last_refresh=CURRENT_TIMESTAMP
    #                     WHERE mv_name=matview;
    # 
    #                 RETURN;
    #             END
    #             ';"
    #             
                
    # execute "CREATE VIEW sen_mostviewed_aggs_v AS 
    #              SELECT people.*, 
    #              COALESCE(person_approvals.person_approval_avg, 0) as person_approval_average,
    #              COALESCE(bills_sponsored.sponsored_bills_count, 0) as sponsored_bills_count,
    #              COALESCE(total_rolls.tcalls, 0) as total_roll_call_votes,
    #              CASE WHEN people.party = 'Democrat' THEN COALESCE(party_votes_democrat.pcount, 0)
    #              WHEN people.party = 'Republican' THEN COALESCE(party_votes_republican.pcount, 0)
    #              ELSE 0
    #              END as party_roll_call_votes,
    #              COALESCE(most_viewed.view_count, 0) as view_count,
    #              COALESCE(blogs.blog_count, 0) as blog_count,
    #              COALESCE(news.news_count, 0) as news_count
    #              FROM people
    #              LEFT OUTER JOIN roles on roles.person_id=people.id 
    #              LEFT OUTER JOIN (select person_approvals.person_id as person_approval_id, 
    #              count(person_approvals.id) as person_approval_count, 
    #              avg(person_approvals.rating) as person_approval_avg 
    #              FROM person_approvals
    #              GROUP BY person_approval_id) person_approvals
    #              ON person_approval_id = people.id
    #              LEFT OUTER JOIN (select sponsor_id, count(id) as sponsored_bills_count
    #              FROM bills
    #              WHERE bills.session = 111
    #              GROUP BY sponsor_id) bills_sponsored
    #              ON bills_sponsored.sponsor_id = people.id
    #              LEFT OUTER JOIN (SELECT DISTINCT(roll_call_votes.person_id), count(DISTINCT roll_calls.id) AS tcalls 
    #              FROM roll_calls
    #              LEFT OUTER JOIN bills ON bills.id = roll_calls.bill_id 
    #              INNER JOIN roll_call_votes ON roll_calls.id = roll_call_votes.roll_call_id 
    #              WHERE roll_call_votes.vote != '0' AND bills.session = 111
    #              GROUP BY roll_call_votes.person_id) total_rolls
    #                  ON total_rolls.person_id = people.id
    #              LEFT OUTER JOIN (SELECT DISTINCT(roll_call_votes.person_id), count(DISTINCT roll_calls.id) AS pcount 
    #              FROM roll_calls 
    #              LEFT OUTER JOIN bills ON bills.id = roll_calls.bill_id 
    #              INNER JOIN roll_call_votes ON roll_calls.id = roll_call_votes.roll_call_id 
    #              WHERE ((roll_calls.democratic_position = true AND vote = '+') OR (roll_calls.democratic_position = false AND vote = '-')) 
    #              AND bills.session = 111
    #              GROUP BY roll_call_votes.person_id) party_votes_democrat
    #                ON party_votes_democrat.person_id = people.id
    #                LEFT OUTER JOIN (SELECT DISTINCT(roll_call_votes.person_id), count(DISTINCT roll_calls.id) AS pcount 
    #                FROM roll_calls 
    #                LEFT OUTER JOIN bills ON bills.id = roll_calls.bill_id 
    #                INNER JOIN roll_call_votes ON roll_calls.id = roll_call_votes.roll_call_id 
    #                WHERE ((roll_calls.republican_position = true AND vote = '+') OR (roll_calls.republican_position = false AND vote = '-')) 
    #                AND bills.session = 111
    #                  GROUP BY roll_call_votes.person_id) party_votes_republican
    #                    ON party_votes_republican.person_id = people.id
    #              LEFT OUTER JOIN (SELECT page_views.viewable_id,
    #              count(page_views.viewable_id) AS view_count_7
    #              FROM page_views 
    #              WHERE page_views.created_at > current_timestamp - interval '7 days' AND
    #              page_views.viewable_type = 'Person'
    #              GROUP BY page_views.viewable_id
    #              ORDER BY view_count DESC) most_viewed
    #              ON people.id=most_viewed.viewable_id
    #              LEFT OUTER JOIN (SELECT count(commentaries.id) as blog_count, commentaries.commentariable_id
    #              FROM commentaries 
    #              WHERE commentaries.date > current_timestamp - interval '7 days' AND
    #              commentaries.is_news = 'f' AND 
    #              commentaries.commentariable_type = 'Person'
    #              GROUP BY commentaries.commentariable_id
    #              ORDER BY blog_count DESC) blogs
    #              ON people.id=blogs.commentariable_id 
    #              LEFT OUTER JOIN (SELECT count(commentaries.id) as news_count, commentaries.commentariable_id
    #              FROM commentaries 
    #              WHERE commentaries.date > current_timestamp - interval '7 days' AND
    #              commentaries.commentariable_type = 'Person' AND commentaries.is_news = 't'
    #              GROUP BY commentaries.commentariable_id
    #              ORDER BY news_count DESC) news
    #              ON people.id=news.commentariable_id       
    #              WHERE roles.role_type = E'sen' AND roles.startdate <= NOW() AND roles.enddate >= NOW() ORDER BY view_count desc"
    # execute "SELECT create_matview('sen_mostviewed_aggs_mv', 'sen_mostviewed_aggs_v');"
    
    
    create_table :object_aggregates, :id => false do |t|
      t.string :aggregatable_type
      t.integer :aggregatable_id
      t.date :date
      t.integer :page_views_count, :comments_count, :blog_articles_count, :news_articles_count, :bookmarks_count, :votes_support, :votes_oppose, :default => 0
    end
    add_index :object_aggregates, [:aggregatable_type, :aggregatable_id], :name => 'aggregatable_poly_idx'
    add_index :object_aggregates, :date
    
    execute "CREATE OR REPLACE FUNCTION aggregate_increment()
                RETURNS trigger AS '
                DECLARE
                    object_type varchar;
                    object_id integer;
                    column_name varchar;
                    agg_date date;
                    
                    entry object_aggregates%ROWTYPE;

                BEGIN
                  IF (TG_TABLE_NAME = ''page_views'') THEN
                    object_type := NEW.viewable_type;
                    object_id := NEW.viewable_id;
                    column_name := ''page_views_count'';
                    agg_date := NEW.created_at;
                  ELSIF (TG_TABLE_NAME = ''comments'') THEN
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
                      IF (NEW.support = 1) THEN
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
            
     execute "CREATE TRIGGER aggregate_pageview_trigger BEFORE INSERT ON page_views FOR EACH ROW EXECUTE PROCEDURE aggregate_increment();"
     execute "CREATE TRIGGER aggregate_comment_trigger BEFORE INSERT ON comments FOR EACH ROW EXECUTE PROCEDURE aggregate_increment();"
     execute "CREATE TRIGGER aggregate_bookmark_trigger BEFORE INSERT ON bookmarks FOR EACH ROW EXECUTE PROCEDURE aggregate_increment();"
     execute "CREATE TRIGGER aggregate_bill_votes_trigger BEFORE INSERT ON bill_votes FOR EACH ROW EXECUTE PROCEDURE aggregate_increment();"
     execute "CREATE TRIGGER aggregate_commentaries_trigger BEFORE INSERT ON commentaries FOR EACH ROW EXECUTE PROCEDURE aggregate_increment();"
      
    #   
    # puts "Getting dates..."
    # 
    # 
    # bills = Bill.find(:all, :conditions => 'session=111')
    # bills.each_with_index do |b, i|
    #   puts "Bill #{i+1} of #{bills.size}"
    #   d = Date.parse('01-01-2009')
    #   while (d <= Date.today) do
    #     
    #     #puts "Date: #{d}"
    #     oa = ObjectAggregate.create(:aggregatable_type => 'Bill', :aggregatable_id => b.id, :date => d)
    #     
    #     oa.page_views_count = PageView.count_by_sql("SELECT count(*) AS count_all FROM page_views WHERE (created_at >= '#{d}') AND (created_at < '#{d+1}') AND (page_views.viewable_id = #{b.id} AND page_views.viewable_type = E'Bill');")
    #     oa.save
    #     
    #     d = d + 1
    #   end
    # end
  end

  def self.down
    # execute "DROP FUNCTION create_matview(NAME, NAME);"
    # execute "DROP FUNCTION drop_matview(NAME);"
    # execute "DROP FUNCTION refresh_matview(name);"
    # execute "DROP TABLE matviews"
    # 
    #execute "DROP VIEW sen_mostviewed_aggs_v"
    
    drop_table :object_aggregates
    execute "DROP TRIGGER aggregate_pageview_trigger ON page_views"
    execute "DROP TRIGGER aggregate_comment_trigger ON comments"
    execute "DROP TRIGGER aggregate_bookmark_trigger ON bookmarks"
    execute "DROP TRIGGER aggregate_bill_votes_trigger ON bill_votes"
    execute "DROP TRIGGER aggregate_commentaries_trigger ON commentaries"
    execute "DROP FUNCTION aggregate_increment()"
  end
end
