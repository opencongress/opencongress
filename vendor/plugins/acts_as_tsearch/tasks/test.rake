#instead of doing what's below .... just modify template1
#   mac-san:~ wiseleyb$ locate tsearch2.sql
#   /usr/local/pgsql/share/contrib/tsearch2.sql
#   mac-san:~ wiseleyb$ sudo su postgres
#   Password:
#   mac-san:/Users/wiseleyb postgres$  psql template1 < /usr/local/pgsql/share/contrib/tsearch2.sql        

#old method - if you can't modify template1 because of dilbert rules at work... welcome to hell ...

# module Rake
#   module TaskManager
#     def redefine_task(task_class, args, &block)
#       task_name, deps = resolve_args(args)
#       task_name = task_class.scope_name(@scope, task_name)
#       deps = [deps] unless deps.respond_to?(:to_ary)
#       deps = deps.collect {|d| d.to_s }
#       task = @tasks[task_name.to_s] = task_class.new(task_name, self)
#       task.application = self
#       task.add_comment(@last_comment)
#       @last_comment = nil
#       task.enhance(deps, &block)
#       task
#     end
#   end
#   class Task
#     class << self
#       def redefine_task(args, &block)
#         Rake.application.redefine_task(self, args, &block)
#       end
#     end
#   end
# end
# 
# def redefine_task(args, &block)
#   Rake::Task.redefine_task(args, &block)
# end
# 
# namespace :db do
#    namespace :test do
#     desc "Empty the test database but don't drop it if it already exists"
#     redefine_task :purge => :environment do
#       abcs = ActiveRecord::Base.configurations
#       case abcs["test"]["adapter"]
#         when "postgresql"
#           #this if from http://dev.rubyonrails.org/attachment/ticket/7665/mah_databases.rake.diff
#           # if schema defined, drop/create schema, otherwise drop/create db 
#           if abcs["test"]["schema_search_path"] 
#             def_schema = abcs["test"]["schema_search_path"].split(',')[0] 
#             ActiveRecord::Base.establish_connection(:test) 
#             ActiveRecord::Base.connection.execute("DROP SCHEMA #{def_schema} CASCADE") 
#             ActiveRecord::Base.connection.execute("CREATE SCHEMA #{def_schema}")
#           else 
#             ENV['PGHOST']     = abcs["test"]["host"] if abcs["test"]["host"] 
#             ENV['PGPORT']     = abcs["test"]["port"].to_s if abcs["test"]["port"] 
#             ENV['PGPASSWORD'] = abcs["test"]["password"].to_s if abcs["test"]["password"] 
#             enc_option = "-E #{abcs["test"]["encoding"]}" if abcs["test"]["encoding"]
#             ActiveRecord::Base.clear_active_connections! 
#             begin
#               `dropdb -U "#{abcs["test"]["username"]}" #{abcs["test"]["database"]}` 
#             rescue
#             end
#             `createdb #{enc_option} -U "#{abcs["test"]["username"]}" #{abcs["test"]["database"]}` 
#             `sudo ./vendor/plugins/acts_as_tsearch/dbsetup.sh #{abcs["test"]["database"]} #{abcs["test"]["username"]}`
#           end        
#         else
#           raise "Task not supported by '#{abcs["test"]["adapter"]}'"
#       end
#     end
#    end
#  end