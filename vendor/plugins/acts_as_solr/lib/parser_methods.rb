module ActsAsSolr #:nodoc:
  module ParserMethods
    protected    
    
    # Method used by mostly all the ClassMethods when doing a search
    def parse_query(query=nil, options={}, models=nil)
      
      valid_options = [:offset, :limit, :facets, :models, :results_format, :order, :scores, :operator, :include, :lazy, :highlight]
      query_options = {}

      return nil if (query.nil? || query.strip == '')

      raise "Invalid parameters: #{(options.keys - valid_options).join(',')}" unless (options.keys - valid_options).empty?
      begin
        Deprecation.validate_query(options)
        query_options[:start] = options[:offset]
        query_options[:rows] = options[:limit]
        query_options[:operator] = options[:operator]

        if options[:highlight] == true
          options[:highlight] = {:fields => "*"}
        end
        
        if options[:highlight]
          query_options[:highlighting] = {}
          query_options[:highlighting][:field_list] = []
          query_options[:highlighting][:field_list] << options[:highlight][:fields].collect {|k| "#{k}_t"} if options[:highlight][:fields]
          query_options[:highlighting][:require_field_match] =  options[:highlight][:require_field_match] if options[:highlight][:require_field_match]
          query_options[:highlighting][:max_snippets] = options[:highlight][:max_snippets] if options[:highlight][:max_snippets]
          query_options[:highlighting][:prefix] = options[:highlight][:prefix] if options[:highlight][:prefix]
          query_options[:highlighting][:suffix] = options[:highlight][:suffix] if options[:highlight][:suffix]
        end
        
        # first steps on the facet parameter processing
        if options[:facets]
          query_options[:facets] = {}
          query_options[:facets][:limit] = -1  # TODO: make this configurable
          query_options[:facets][:sort] = :count if options[:facets][:sort]
          query_options[:facets][:mincount] = 0
          query_options[:facets][:mincount] = 1 if options[:facets][:zeros] == false
          # override the :zeros (it's deprecated anyway) if :mincount exists
          query_options[:facets][:mincount] = options[:facets][:mincount] if options[:facets][:mincount]
          query_options[:facets][:fields] = options[:facets][:fields].collect{|k| "#{k}_facet"} if options[:facets][:fields]
          query_options[:filter_queries] = replace_types([*options[:facets][:browse]].collect{|k| "#{k.sub!(/ *: */,"_facet:")}"}) if options[:facets][:browse]
          query_options[:facets][:queries] = replace_types(options[:facets][:query].collect{|k| "#{k.sub!(/ *: */,"_t:")}"}) if options[:facets][:query]
          
          if options[:facets][:dates]
            query_options[:date_facets] = {}
            # if options[:facets][:dates][:fields] exists then :start, :end, and :gap must be there
            if options[:facets][:dates][:fields]
              [:start, :end, :gap].each { |k| raise "#{k} must be present in faceted date query" unless options[:facets][:dates].include?(k) }
              query_options[:date_facets][:fields] = []
              options[:facets][:dates][:fields].each { |f|
                if f.kind_of? Hash
                  key = f.keys[0]
                  query_options[:date_facets][:fields] << {"#{key}_d" => f[key]}
                  validate_date_facet_other_options(f[key][:other]) if f[key][:other]
                else
                  query_options[:date_facets][:fields] << "#{f}_d"
                end
              }
            end
            
            query_options[:date_facets][:start]   = options[:facets][:dates][:start] if options[:facets][:dates][:start]
            query_options[:date_facets][:end]     = options[:facets][:dates][:end] if options[:facets][:dates][:end]
            query_options[:date_facets][:gap]     = options[:facets][:dates][:gap] if options[:facets][:dates][:gap]
            query_options[:date_facets][:hardend] = options[:facets][:dates][:hardend] if options[:facets][:dates][:hardend]
            query_options[:date_facets][:filter]  = replace_types([*options[:facets][:dates][:filter]].collect{|k| "#{k.sub!(/ *:(?!\d) */,"_d:")}"}) if options[:facets][:dates][:filter]

            if options[:facets][:dates][:other]
              validate_date_facet_other_options(options[:facets][:dates][:other])
              query_options[:date_facets][:other]   = options[:facets][:dates][:other]
            end
            
          end          
        end
        
        if models.nil?
          # TODO: use a filter query for type, allowing Solr to cache it individually
          models = "AND #{solr_type_condition}"
          field_list = solr_configuration[:primary_key_field]
        else
          field_list = "id"
        end
        
        query_options[:field_list] = [field_list, 'score']
        query = "(" + query.gsub(/([a-z_][a-z0-9_]*) *: */,"\\1_t:") + ") #{models}"
        order = options[:order].split(/\s*,\s*/).collect{|e| e.gsub(/\s+/,'_t ').gsub(/\bscore_t\b/, 'score')  }.join(',') if options[:order] 
        query_options[:query] = replace_types([query])[0] # TODO adjust replace_types to work with String or Array  

        if options[:order].is_a?(String)  
          string = replace_types([order], false)[0]
          field, direction = string.split(/\s+/)
          direction = direction.to_s =~ /asc/i ? :ascending : :descending
          query_options[:sort] = [{field => direction}]
        elsif options[:order]
          query_options[:sort] = options[:order]
        end
        ActsAsSolr::Post.execute(Solr::Request::Standard.new(query_options))
      rescue
        raise "There was a problem executing your search: #{$!} in #{$!.backtrace.first}"
      end            
    end
    
    def solr_type_condition
      subclasses.inject("(#{solr_configuration[:type_field]}:\"#{self.name}\"") do |condition, subclass|
        condition << " OR #{solr_configuration[:type_field]}:\"#{subclass.name}\""
      end << ')'
    end
    
    # Parses the data returned from Solr
    def parse_results(solr_data, options = {})
      results = {
        :docs => [],
        :total => 0
      }
      
      configuration = {
        :format => :objects
      }
      results.update(:facets => {'facet_fields' => []}) if options[:facets]
      return SearchResults.new(results) if (solr_data.nil? || solr_data.total_hits == 0)
      
      configuration.update(options) if options.is_a?(Hash)

      ids = solr_data.hits.collect {|doc| doc["#{solr_configuration[:primary_key_field]}"]}.flatten
      
      result = find_objects(ids, options, configuration)
      
      add_scores(result, solr_data) if configuration[:format] == :objects && options[:scores]
      
      highlighted = {}
      solr_data.highlighting.map do |x,y| 
        e={}
        y1=y.map{|x1,y1| e[x1.gsub(/_[^_]*/,"")]=y1} unless y.nil?
        highlighted[x.gsub(/[^:]*:/,"").to_i]=e
      end unless solr_data.highlighting.nil?
      
      results.update(:facets => solr_data.data['facet_counts']) if options[:facets]
      results.update({:docs => result, :total => solr_data.total_hits, :max_score => solr_data.max_score, :query_time => solr_data.data['responseHeader']['QTime']})
      results.update({:highlights=>highlighted})
      
      
      sr = SearchResults.new(results)

      sr.records.each do |model|
        model.init_solr(results) if model.respond_to?(:init_solr)
      end if sr.records
      
      sr
    end
    
    
    def find_objects(ids, options, configuration)
      result = if configuration[:lazy] && configuration[:format] != :ids
        ids.collect {|id| ActsAsSolr::LazyDocument.new(id, self)}
      elsif configuration[:format] == :objects
        conditions = [ "#{self.table_name}.#{primary_key} in (?)", ids ]
        find_options = {:conditions => conditions}
        find_options[:include] = options[:include] if options[:include]
        result = reorder(self.find(:all, find_options), ids)
      else
        ids
      end
        
      result
    end
    
    # Reorders the instances keeping the order returned from Solr
    def reorder(things, ids)
      ordered_things = Array.new([things.size, ids.size].max)
      # raise "Out of sync! Found #{ids.size} items in index, but only #{things.size} were found in database!" unless things.size == ids.size
      things.each do |thing|
        position = ids.index(thing.id)
        ordered_things[position] = thing
      end
      ordered_things.compact
    end

    # Replaces the field types based on the types (if any) specified
    # on the acts_as_solr call
    def replace_types(strings, include_colon=true)
      suffix = include_colon ? ":" : ""
      if configuration[:solr_fields]
        configuration[:solr_fields].each do |name, options|
          solr_name = options[:as] || name.to_s
          solr_type = get_solr_field_type(options[:type])
          field = "#{solr_name}_#{solr_type}#{suffix}"
          strings.each_with_index {|s,i| strings[i] = s.gsub(/#{solr_name.to_s}_t#{suffix}/,field) }
        end
      end
      if configuration[:solr_includes]
        configuration[:solr_includes].each do |association, options|
          solr_name = options[:as] || association.to_s.singularize
          solr_type = get_solr_field_type(options[:type])
          field = "#{solr_name}_#{solr_type}#{suffix}"
          strings.each_with_index {|s,i| strings[i] = s.gsub(/#{solr_name.to_s}_t#{suffix}/,field) }
        end
      end
      strings
    end
    
    # Adds the score to each one of the instances found
    def add_scores(results, solr_data)
      with_score = []
      solr_data.hits.each do |doc|
        with_score.push([doc["score"], 
          results.find {|record| scorable_record?(record, doc) }])
      end
      with_score.each do |score, object| 
        class << object; attr_accessor :solr_score; end
        object.solr_score = score
      end
    end
    
    def scorable_record?(record, doc)
      doc_id = doc["#{solr_configuration[:primary_key_field]}"]
      if doc_id.nil?
        doc_id = doc["id"]
        "#{record.class.name}:#{record_id(record)}" == doc_id.first.to_s
      else
        record_id(record).to_s == doc_id.to_s
      end
    end
    
    def validate_date_facet_other_options(options)
      valid_other_options = [:after, :all, :before, :between, :none]
      options = [options] unless options.kind_of? Array
      bad_options = options.map {|x| x.to_sym} - valid_other_options
      raise "Invalid option#{'s' if bad_options.size > 1} for faceted date's other param: #{bad_options.join(', ')}. May only be one of :after, :all, :before, :between, :none" if bad_options.size > 0
    end
    
  end
end
