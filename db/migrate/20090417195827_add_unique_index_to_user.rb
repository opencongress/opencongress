class AddUniqueIndexToUser < ActiveRecord::Migration
  def self.up
    User.fix_duplicate_users
    execute "create unique index u_users on users (login);"
    execute "create unique index u_email on users (email);"
  end

  def self.down
  end
end
