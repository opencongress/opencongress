namespace :db do
  namespace :structure do
    desc "Install db/development_structure.sql items - in leiu of db:migrate"
    task :load => :environment do
      seeds_fn = File.join(Rails.root,'db','development_structure.sql')
      if File.exists?(seeds_fn)
        load_pgsql_files(seeds_fn)
      end
    end

    def load_pgsql_files(*fns)
      abcs = ActiveRecord::Base.configurations
      ENV['PGHOST']     = abcs[Rails.env]["host"] if abcs[Rails.env]["host"]
      ENV['PGPORT']     = abcs[Rails.env]["port"].to_s if abcs[Rails.env]["port"]
      ENV['PGPASSWORD'] = abcs[Rails.env]["password"].to_s if abcs[Rails.env]["password"]

      `createlang plpgsql -U "#{abcs[Rails.env]["username"]}" #{abcs[Rails.env]["database"]}`

      fns.each do |fn|
        `psql -U "#{abcs[Rails.env]["username"]}" -f #{fn} #{abcs[Rails.env]["database"]}`
      end
    end
  end
end