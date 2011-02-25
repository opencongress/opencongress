module ActsAsTaggableOn::Taggable
  module Core
    module ClassMethods
      def tagged_with(tags, options = {})
        tag_list = ActsAsTaggableOn::TagList.from(tags)

        return {} if tag_list.empty?

        joins = []
        conditions = []

        context = options.delete(:on)

        if options.delete(:exclude)
          tags_conditions = tag_list.map { |t| sanitize_sql(["#{ActsAsTaggableOn::Tag.table_name}.name ILIKE ?", t]) }.join(" OR ")
          conditions << "#{table_name}.#{primary_key} NOT IN (SELECT #{ActsAsTaggableOn::Tagging.table_name}.taggable_id FROM #{ActsAsTaggableOn::Tagging.table_name} JOIN #{ActsAsTaggableOn::Tag.table_name} ON #{ActsAsTaggableOn::Tagging.table_name}.tag_id = #{ActsAsTaggableOn::Tag.table_name}.id AND (#{tags_conditions}) WHERE #{ActsAsTaggableOn::Tagging.table_name}.taggable_type = #{quote_value(base_class.name)})"

        elsif options.delete(:any)
          tags_conditions = tag_list.map { |t| sanitize_sql(["#{ActsAsTaggableOn::Tag.table_name}.name ILIKE ?", t]) }.join(" OR ")
          conditions << "#{table_name}.#{primary_key} IN (SELECT #{ActsAsTaggableOn::Tagging.table_name}.taggable_id FROM #{ActsAsTaggableOn::Tagging.table_name} JOIN #{ActsAsTaggableOn::Tag.table_name} ON #{ActsAsTaggableOn::Tagging.table_name}.tag_id = #{ActsAsTaggableOn::Tag.table_name}.id AND (#{tags_conditions}) WHERE #{ActsAsTaggableOn::Tagging.table_name}.taggable_type = #{quote_value(base_class.name)})"

        else
          tags = ActsAsTaggableOn::Tag.named_any(tag_list)
          return scoped(:conditions => "1 = 0") unless tags.length == tag_list.length

          tags.each do |tag|
            safe_tag = tag.name.gsub(/[^a-zA-Z0-9]/, '')
            prefix   = "#{safe_tag}_#{rand(1024)}"

            taggings_alias = "#{undecorated_table_name}_taggings_#{prefix}"

            tagging_join  = "JOIN #{ActsAsTaggableOn::Tagging.table_name} #{taggings_alias}" +
                            "  ON #{taggings_alias}.taggable_id = #{table_name}.#{primary_key}" +
                            " AND #{taggings_alias}.taggable_type = #{quote_value(base_class.name)}" +
                            " AND #{taggings_alias}.tag_id = #{tag.id}"
            tagging_join << " AND " + sanitize_sql(["#{taggings_alias}.context = ?", context.to_s]) if context

            joins << tagging_join
          end
        end

        taggings_alias, tags_alias = "#{undecorated_table_name}_taggings_group", "#{undecorated_table_name}_tags_group"

        if options.delete(:match_all)
          joins << "LEFT OUTER JOIN #{ActsAsTaggableOn::Tagging.table_name} #{taggings_alias}" +
                   "  ON #{taggings_alias}.taggable_id = #{table_name}.#{primary_key}" +
                   " AND #{taggings_alias}.taggable_type = #{quote_value(base_class.name)}"


          group_columns = ActsAsTaggableOn::Tag.using_postgresql? ? grouped_column_names_for(self) : "#{table_name}.#{primary_key}"
          group = "#{group_columns} HAVING COUNT(#{taggings_alias}.taggable_id) = #{tags.size}"
        end


        scoped(:joins      => joins.join(" "),
               :group      => group,
               :conditions => conditions.join(" AND "),
               :order      => options[:order],
               :readonly   => false)
      end

      def is_taggable?
        true
      end
    end
  end
end