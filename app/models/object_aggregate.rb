class ObjectAggregate < ActiveRecord::Base
  belongs_to :aggregatable, :polymorphic => true
  
  def self.popular(viewable_type, seconds = DEFAULT_COUNT_TIME, limit = 20, congress = DEFAULT_CONGRESS, frontpage_hot = false)
    associated_class = Object.const_get(viewable_type)

    where_clause = ""
    if (viewable_type == 'Bill')
      where_clause = "WHERE bills.session=#{congress}"
      where_clause += " AND bills.is_frontpage_hot = 't'" if frontpage_hot
    end
      
    associated_class.find_by_sql(["SELECT #{associated_class.table_name}.*, 
                                          most_viewed.view_count AS view_count 
                                   FROM #{associated_class.table_name} 
                                   INNER JOIN
                                   (SELECT object_aggregates.aggregatable_id,
                                           sum(object_aggregates.page_views_count) AS view_count
                                    FROM object_aggregates 
                                    WHERE object_aggregates.date >= ? AND
                                          object_aggregates.aggregatable_type = ?
                                    GROUP BY object_aggregates.aggregatable_id
                                    ORDER BY view_count DESC) most_viewed
                                   ON #{associated_class.table_name}.id=most_viewed.aggregatable_id
                                   #{where_clause}
                                   ORDER BY view_count DESC LIMIT ?", 
                                  seconds.ago, viewable_type, limit])
  end
end