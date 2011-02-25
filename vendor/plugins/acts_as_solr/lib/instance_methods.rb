module ActsAsSolr #:nodoc:
  
  module InstanceMethods

    # Solr id is <class.name>:<id> to be unique across all models
    def solr_id
      "#{self.class.name}:#{record_id(self)}"
    end
    
    def init_solr(data)
      @solr_data = data
    end
    
    def method_missing_with_solr_magic(method, *a, &b)
      if method.to_s =~ /^highlighted_(.*)$/ && a.length == 0
        original_field = $1
        @solr_data && @solr_data[:highlights] && @solr_data[:highlights][id] && 
          @solr_data[:highlights][id][original_field] && 
          @solr_data[:highlights][id][original_field].join(" ") || send(original_field)
      else
        method_missing_without_solr_magic(method, *a, &b)
      end
    end

    # saves to the Solr index
    def solr_save
      if self.class.respond_to?(:acts_as_solr_needs_reload?) && self.class.acts_as_solr_needs_reload?
        self.class.acts_as_solr 
      end
      
      return true if indexing_disabled?
      if evaluate_condition(:if, self) 
        logger.debug "solr_save: #{self.class.name} : #{record_id(self)}"
        solr_add to_solr_doc
        solr_commit if configuration[:auto_commit]
        true
      else
        solr_destroy
      end
    rescue ConnectionError
      false
    end

    def indexing_disabled?
      evaluate_condition(:offline, self) || !configuration[:if]
    end

    # remove from index
    def solr_destroy
      return true if indexing_disabled?
      logger.debug "solr_destroy: #{self.class.name} : #{record_id(self)}"
      solr_delete solr_id
      solr_commit if configuration[:auto_commit]
      true
    rescue ConnectionError
      false
    end

    # convert instance to Solr document
    def to_solr_doc
      logger.debug "to_solr_doc: creating doc for class: #{self.class.name}, id: #{record_id(self)}"
      doc = Solr::Document.new
      doc.boost = validate_boost(configuration[:boost]) if configuration[:boost]
      
      doc << {:id => solr_id,
              solr_configuration[:type_field] => self.class.name,
              solr_configuration[:primary_key_field] => record_id(self).to_s}

      # iterate through the fields and add them to the document,
      configuration[:solr_fields].each do |field_name, options|
        #field_type = configuration[:facets] && configuration[:facets].include?(field) ? :facet : :text
        
        field_boost = options[:boost] || solr_configuration[:default_boost]
        field_type = get_solr_field_type(options[:type])
        solr_name = options[:as] || field_name
        
        value = self.send("#{field_name}_for_solr")
        value = set_value_if_nil(field_type) if value.to_s == ""
        
        # add the field to the document, but only if it's not the id field
        # or the type field (from single table inheritance), since these
        # fields have already been added above.
        if field_name.to_s != self.class.primary_key and field_name.to_s != "type"
          suffix = get_solr_field_type(field_type)
          # This next line ensures that e.g. nil dates are excluded from the 
          # document, since they choke Solr. Also ignores e.g. empty strings, 
          # but these can't be searched for anyway: 
          # http://www.mail-archive.com/solr-dev@lucene.apache.org/msg05423.html
          next if value.nil? || value.to_s.strip.empty?
          [value].flatten.each do |v|
            v = set_value_if_nil(suffix) if value.to_s == ""
            field = Solr::Field.new("#{solr_name}_#{suffix}" => ERB::Util.html_escape(v.to_s))
            field.boost = validate_boost(field_boost)
            doc << field
          end
        end
      end
      
      add_includes(doc)
      logger.debug doc.to_xml
      doc
    end
    
    private
    def add_includes(doc)
      if configuration[:solr_includes].respond_to?(:each)
        configuration[:solr_includes].each do |association, options|
          data = options[:multivalued] ? [] : ""
          field_name = options[:as] || association.to_s.singularize
          field_type = get_solr_field_type(options[:type])
          field_boost = options[:boost] || solr_configuration[:default_boost]
          suffix = get_solr_field_type(field_type)
          case self.class.reflect_on_association(association).macro
          when :has_many, :has_and_belongs_to_many
            records = self.send(association).to_a
            unless records.empty?
              records.each {|r| data << include_value(r, options)}
              [data].flatten.each do |value|
                field = Solr::Field.new("#{field_name}_#{suffix}" => value)
                field.boost = validate_boost(field_boost)
                doc << field
              end
            end
          when :has_one, :belongs_to
            record = self.send(association)
            unless record.nil?
              doc["#{field_name}_#{suffix}"] = include_value(record, options)
            end
          end
        end
      end
    end
    
    def include_value(record, options)
      if options[:using].is_a? Proc
        options[:using].call(record)
      elsif options[:using].is_a? Symbol
        record.send(options[:using])
      else
        record.attributes.inject([]){|k,v| k << "#{v.first}=#{ERB::Util.html_escape(v.last)}"}.join(" ")
      end
    end

    def validate_boost(boost)
      boost_value = case boost
      when Float
        return solr_configuration[:default_boost] if boost < 0
        boost
      when Proc
        boost.call(self)
      when Symbol
        if self.respond_to?(boost)
          self.send(boost)
        end
      end
      
      boost_value || solr_configuration[:default_boost]
    end
    
    def condition_block?(condition)
      condition.respond_to?("call") && (condition.arity == 1 || condition.arity == -1)
    end
    
    def evaluate_condition(which_condition, field)
      condition = configuration[which_condition]
      case condition
        when Symbol
          field.send(condition)
        when String
          eval(condition, binding)
        when FalseClass, NilClass
          false
        when TrueClass
          true
        else
          if condition_block?(condition)
            condition.call(field)
          else
            raise(
              ArgumentError,
              "The :#{which_condition} option has to be either a symbol, string (to be eval'ed), proc/method, true/false, or " +
              "class implementing a static validation method"
            )
          end
        end
    end
    
  end
end