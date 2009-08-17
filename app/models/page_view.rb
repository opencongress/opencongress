class PageView < ActiveRecord::Base
  belongs_to :viewable, :polymorphic => true, :counter_cache => true

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
                                   (SELECT page_views.viewable_id,
                                           count(page_views.viewable_id) AS view_count
                                    FROM page_views 
                                    WHERE page_views.created_at > ? AND
                                          page_views.viewable_type = ?
                                    GROUP BY page_views.viewable_id
                                    ORDER BY view_count DESC) most_viewed
                                   ON #{associated_class.table_name}.id=most_viewed.viewable_id
                                   #{where_clause}
                                   ORDER BY view_count DESC LIMIT ?", 
                                  seconds.ago, viewable_type, limit])
  end
  
  def self.create_by_hour(viewable, request)
    view = viewable.page_views.find(:first, :conditions => ["ip_address = ? AND created_at > ?", request.remote_ip, 1.hour.ago])
    
    unless view
      viewable.page_views.create(:ip_address => request.remote_ip, 
                         :referrer => ((/www\.opencongress\.org/.match(request.referer)) ? '' : request.referer))
    end
  end
end

