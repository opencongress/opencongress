class OtherAggregates < ActiveRecord::Migration
  def self.up
    
    execute "UPDATE object_aggregates SET bookmarks_count=agg.b_count FROM
               (SELECT bookmarkable_type as b_type, bookmarkable_id as b_id, created_at::date as date, 
                      count(id) as b_count 
               FROM bookmarks GROUP BY b_type, b_id, created_at::date) agg
               WHERE object_aggregates.aggregatable_id=agg.b_id AND object_aggregates.aggregatable_type=agg.b_type AND object_aggregates.date=agg.date"
         
    execute "UPDATE object_aggregates SET comments_count=agg.c_count FROM
              (SELECT commentable_type as c_type, commentable_id as c_id, created_at::date as date, 
                     count(id) as c_count 
              FROM comments GROUP BY c_type, c_id, created_at::date) agg
              WHERE object_aggregates.aggregatable_id=agg.c_id AND object_aggregates.aggregatable_type=agg.c_type AND object_aggregates.date=agg.date"
              
    execute "UPDATE object_aggregates SET votes_support=agg.sp_count FROM
              (SELECT bill_id as b_id, created_at::date as date, 
                     count(id) as sp_count 
              FROM bill_votes WHERE support='0' GROUP BY b_id, created_at::date) agg
              WHERE object_aggregates.aggregatable_id=agg.b_id AND object_aggregates.aggregatable_type='Bill' AND object_aggregates.date=agg.date"
               
    execute "UPDATE object_aggregates SET votes_oppose=agg.sp_count FROM
             (SELECT bill_id as b_id, created_at::date as date, 
                    count(id) as sp_count 
             FROM bill_votes WHERE support='1' GROUP BY b_id, created_at::date) agg
             WHERE object_aggregates.aggregatable_id=agg.b_id AND object_aggregates.aggregatable_type='Bill' AND object_aggregates.date=agg.date"
               
    execute "UPDATE object_aggregates SET blog_articles_count=agg.b_count FROM
             (SELECT commentariable_type as c_type, commentariable_id as c_id, date::date as date, 
                    count(id) as b_count 
             FROM commentaries WHERE is_ok='t' AND is_news='f' GROUP BY c_type, c_id, date::date ) agg
             WHERE object_aggregates.aggregatable_id=agg.c_id AND object_aggregates.aggregatable_type=agg.c_type AND object_aggregates.date=agg.date"
    
    execute "UPDATE object_aggregates SET news_articles_count=agg.b_count FROM
            (SELECT commentariable_type as c_type, commentariable_id as c_id, date::date as date, 
                   count(id) as b_count 
            FROM commentaries WHERE is_ok='t' AND is_news='t' GROUP BY c_type, c_id, date::date ) agg
            WHERE object_aggregates.aggregatable_id=agg.c_id AND object_aggregates.aggregatable_type=agg.c_type AND object_aggregates.date=agg.date"
                       
        
    add_column :actions, :govtrack_order, :integer
    
    add_column :people, :total_session_votes, :integer
    add_column :people, :votes_democratic_position, :integer
    add_column :people, :votes_republican_position, :integer
    
    Person.calculate_and_save_party_votes
  end

  def self.down
    remove_column :actions, :govtrack_order
     
    remove_column :people, :total_votes
    remove_column :people, :votes_democratic_position
    remove_column :people, :votes_republican_position

  end
end
