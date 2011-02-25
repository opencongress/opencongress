module ActsAsSolr
  module ClassMethods
    def paginate_by_solr(query, options = {})
      options[:total_entries] ||= count_by_solr(query)
      method_missing :paginate_by_solr, query, options
    end
    
    def find_all_by_solr(*args)
      find_by_solr(*args).records
    end
  end
end