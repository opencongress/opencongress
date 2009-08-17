class ChangeZipToString < ActiveRecord::Migration
  def self.up
    execute "ALTER TABLE users ALTER zipcode TYPE varchar(5);"
    execute "ALTER TABLE users ALTER zip_four TYPE varchar(4);"
  end

  def self.down
  end
end
