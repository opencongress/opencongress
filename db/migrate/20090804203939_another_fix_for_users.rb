class AnotherFixForUsers < ActiveRecord::Migration
  def self.up
    execute "alter table users alter column chat_icq drop default;"
    User.update_all("about = null", ["about = ?", "''::text"])
    User.update_all("chat_icq = null", ["chat_icq = ?", "''::character varying"])

  end

  def self.down
  end
end
