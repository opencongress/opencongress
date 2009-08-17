module ActiveRecord
  module Acts #:nodoc:
    module Taggable #:nodoc:
      def self.included(base)
        base.extend(ClassMethods)  
      end
      
      module ClassMethods
        def acts_as_taggable(options = {})
          write_inheritable_attribute(:acts_as_taggable_options, {
            :taggable_type => ActiveRecord::Base.send(:class_name_of_active_record_descendant, self).to_s,
            :from => options[:from]
          })
          
          class_inheritable_reader :acts_as_taggable_options

          has_many :taggings, :as => :taggable, :dependent => :destroy
          has_many :taggs, :through => :taggings

          include ActiveRecord::Acts::Taggable::InstanceMethods
          extend ActiveRecord::Acts::Taggable::SingletonMethods          
        end
      end
      
      module SingletonMethods
        def find_tagged_with(list)
          find_by_sql([
            "SELECT DISTINCT #{table_name}.* FROM #{table_name}, taggs, taggings " +
            "WHERE #{table_name}.#{primary_key} = taggings.taggable_id " +
            "AND taggings.taggable_type = ? " +
            "AND taggings.tagg_id = taggs.id AND taggs.name IN (?)",
            acts_as_taggable_options[:taggable_type], list
          ])
        end
      end
      
      module InstanceMethods
        def tag_with(list)
          Tagg.transaction do
            taggings.destroy_all

            Tagg.parse(list).each do |name|
              if acts_as_taggable_options[:from]
                send(acts_as_taggable_options[:from]).taggs.find_or_create_by_name(name).on(self)
              else
                Tagg.find_or_create_by_name(name).on(self)
              end
            end
          end
        end

        def tag_list
          taggs.collect { |tag| tag.name.include?(" ") ? "'#{tag.name}'" : tag.name }.join(" ")
        end
        
        def tagged_list
          taggs.collect { |tag| tag.name }
        end
      end
    end
  end
end
