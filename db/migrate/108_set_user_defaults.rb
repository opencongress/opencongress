class SetUserDefaults < ActiveRecord::Migration
  def self.up
    execute "ALTER TABLE users ALTER about SET DEFAULT '';"
    execute "ALTER TABLE users ALTER homepage SET DEFAULT '';"
    execute "ALTER TABLE users ALTER location SET DEFAULT '';"
    execute "ALTER TABLE users ALTER about SET DEFAULT '';"
    execute "UPDATE users SET homepage = '' where homepage is null;"
    execute "UPDATE users SET location = '' where location is null;"
    execute "UPDATE users SET about = '' where about is null;"

  end

  def self.down
  end
end
