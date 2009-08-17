module ActiveRecord
  module ConnectionAdapters

    class PostgreSQLAdapter < AbstractAdapter
      
      alias_method :native_database_types_base, :native_database_types

      def native_database_types #:nodoc:
        native_database_types_base.merge(
          {
            :tsvector    => { :name => "tsvector"},
            :regprocedure =>{ :naem => "regprocedure"}
          }
        )
      end
      
    
    class PostgreSQLColumn < Column #:nodoc:
      private
        alias_method :simplified_type_base, :simplified_type

        # Maps PostgreSQL-specific data types to logical Rails types.
        def simplified_type(field_type)
          case field_type
            when /tsvector/i
              :text
            when /regprocedure/i
              :string
            else
              simplified_type_base(field_type)
          end
        end
    end

    end

  end
end


