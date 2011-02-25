class ActsAsSolr::ParserInstance
  include ActsAsSolr::ParserMethods
  include ActsAsSolr::CommonMethods
  attr_accessor :configuration, :solr_configuration
  
  def table_name
    "documents"
  end
  
  def primary_key
    "id"
  end
  
  def find(*args)
    []
  end
  
  public :parse_results, :reorder, :parse_query, :add_scores, :replace_types
end