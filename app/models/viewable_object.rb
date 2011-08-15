module ViewableObject
  def self.included(includer)
    includer.class_eval do
      has_many :object_aggregates, :as => :aggregatable
    end
  end
  
  def self.abstract_class?
    true
  end
  
  def page_view
    self.object_aggregates.find_or_create_by_date(Date.today).increment!(:page_views_count)
  end
  
  def views(seconds = 0)
    # if the view_count is part of this instance's @attributes use that because it came from
    # the query and will make sense in the context of the page; otherwise, count
    return @attributes['view_count'] if @attributes['view_count']
    
    if seconds <= 0
      @attributes['page_views_count'].nil? ? object_aggregates.sum(:page_views_count) : @attributes['page_views_count'].to_i
    else
      object_aggregates.sum(:page_views_count, :conditions => ["date >= ?", seconds.ago])
    end
  end
end 