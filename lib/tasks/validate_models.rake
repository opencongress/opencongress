# from: http://blog.hasmanythrough.com/articles/2006/08/27/validate-all-your-records
# file: validate_models.rake
# task: rake db:validate_models
namespace :db do
  desc "Run model validations on all model records in database"
  task :validate_models => :environment do
    puts "-- records - model --"
    Dir.glob(Rails.root + '/app/models/**/*.rb').each { |file| require file }
    Object.subclasses_of(ActiveRecord::Base).select { |c|
          c.base_class == c}.sort_by(&:name).each do |klass|
      total = klass.count
      printf "%10d - %s\n", total, klass.name
      chunk_size = 1000
      (total / chunk_size + 1).times do |i|
        chunk = klass.find(:all, :offset => (i * chunk_size), :limit => chunk_size)
        chunk.reject(&:valid?).each do |record|
          puts "#{record.class}: id=#{record.id}"
          p record.errors.full_messages
          puts
        end rescue nil
      end

    end
  end
end

namespace :db do
  desc "Run model validations on all model records in database"
  task :validate_model => :environment do
    puts "-- records - model --"
    Dir.glob(Rails.root + '/app/models/**/*.rb').each { |file| require file }

    Object.subclasses_of(ActiveRecord::Base).select { |c| c.name == ENV["CLASS"]}.each do |klass|
      total = klass.count
      printf "%10d - %s\n", total, klass.name
      chunk_size = 1000
      (total / chunk_size + 1).times do |i|
        chunk = klass.find(:all, :offset => (i * chunk_size), :limit => chunk_size)
        chunk.reject(&:valid?).each do |record|
          puts "#{record.class}: id=#{record.id}"
          p record.errors.full_messages
          puts
        end rescue nil
      end

    end
  end
end
