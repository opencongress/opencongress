class Sector < ActiveRecord::Base
  include ViewableObject
  validates_uniqueness_of :name

  has_many :person_sectors, :include => :person
  has_many :people, :through => :person_sectors
  has_many :comments, :as => :commentable

  # forward slashes in the URL were breaking the links
  #def to_param
  #  "#{id}_#{url_name}"
  #end

  @@DISPLAY_OBJECT_NAME = 'Industry'
  
  def display_object_name
    @@DISPLAY_OBJECT_NAME
  end

  def self.full_text_search(q, options = {})
    Sector.find_by_sql(["SELECT *, rank(fti_names, ?, 1) as tsearch_rank FROM sectors 
                        WHERE fti_names @@ to_tsquery('english', ?) order by tsearch_rank DESC;", q, q])
  end
  
  def ident
    "Industry #{id}"
  end
  
  private
  def url_name
    name.gsub(/[\.\(\)]/, "").gsub(/[-\s]+/, "_").downcase
  end
end
