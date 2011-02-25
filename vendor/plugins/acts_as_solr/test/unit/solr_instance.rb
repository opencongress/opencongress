require 'instance_methods'

class SolrInstance
  include ActsAsSolr::InstanceMethods
  attr_accessor :configuration, :solr_configuration, :name

  def initialize(name = "Chunky bacon!")
    @name = name
  end
  
  def self.primary_key
    "id"
  end
  
  def logger
    @logger ||= Logger.new(StringIO.new)
  end
  
  def record_id(obj)
    10
  end
  
  def boost_rate
    10.0
  end
  
  def irate
    8.0
  end

  def name_for_solr
    name
  end
  
  def id_for_solr
    "bogus"
  end
  
  def type_for_solr
    "humbug"
  end
  
  def get_solr_field_type(args)
    "s"
  end
end