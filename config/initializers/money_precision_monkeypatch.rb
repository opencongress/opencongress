# puts "Warning: money_precision_monkeypatch.rb contains a terrible patch for Rail ticket #5081"
# puts "  -- https://rails.lighthouseapp.com/projects/8994/tickets/5081-undefined-method-money_precision-for-class0x105d7dda8"
# puts
# module ActiveRecord
#   module ConnectionAdapters
#     class PostgreSQLAdapter
#       private
#       def connect
#         @connection = PGconn.connect(*@connection_parameters)
#         PGconn.translate_results = false if PGconn.respond_to?(:translate_results=)
# 
#         # Ignore async_exec and async_query when using postgres-pr.
#         @async = @config[:allow_concurrency] && @connection.respond_to?(:async_exec)
# 
#         # Money type has a fixed precision of 10 in PostgreSQL 8.2 and below, and as of
#         # PostgreSQL 8.3 it has a fixed precision of 19. PostgreSQLColumn.extract_precision
#         # should know about this but can't detect it there, so deal with it here.
#         ActiveRecord::ConnectionAdapters::PostgreSQLColumn.money_precision = (postgresql_version >= 80300) ? 19 : 10
# 
#         configure_connection
#       end
#     end
#   end
# end