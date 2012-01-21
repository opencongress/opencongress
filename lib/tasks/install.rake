namespace :db do
  def setup_env(config = ActiveRecord::Base.configurations)
    ENV['PGHOST']     = config[Rails.env]["host"] if config[Rails.env]["host"]
    ENV['PGUSER']     = config[Rails.env]["username"] if config[Rails.env]["username"]
    ENV['PGPORT']     = config[Rails.env]["port"].to_s if config[Rails.env]["port"]
    ENV['PGPASSWORD'] = config[Rails.env]["password"].to_s if config[Rails.env]["password"]
  end

  def execute_commands( cmds = [] )
    cmds.each do |cmd|
      puts "+ #{cmd}"
      system(cmd)
    end
  end

  desc "Configure a fresh postgres cluster for use"
  task :init => [ :environment ] do
    config = ActiveRecord::Base.configurations
    ActiveRecord::Base.clear_all_connections!
    setup_env
    users = []
    existing_dbs = {}

    config.each do |env, settings|
      users << settings['username'] if settings['username']
      db = settings['database']
      next unless db

      existing_dbs[ db ] ||= []
      existing_dbs[ db ] <<  env
    end

    puts # blank line
    puts "=" * 72
    puts "WARNING!"
    puts "=" * 72
    puts # blank line

    puts "This task will drop the following databases:"
    puts # blank line

    existing_dbs.sort_by {|db,_| db }.each do |db, envs|
      puts "  - #{db} (#{envs.sort.join(', ')})"
    end

    puts # blank line
    puts "If you have any reservations, now is the time to press Ctrl-C to cancel."
    puts "Otherwise, hit enter to continue."
    $stdout.flush ; $stdin.gets

    puts # blank line
    puts "Fantastic. Off we go..."

    cmds = []
    pp users.uniq
    users.uniq.each do |user|
      cmds << "createuser -s #{user}"
    end

    existing_dbs.keys.each do |db|
      cmds << "dropdb #{db}"
      cmds << "createdb #{db}"
      cmds << "createlang -d #{db} plpgsql"
    end
    execute_commands cmds
  end
end
