class FixUsers < ActiveRecord::Migration
  def self.up
execute "alter table users alter column homepage drop default;"
execute "alter table users alter column location drop default;"
execute "alter table users alter column about drop default;"
execute "alter table users alter column chat_aim drop default;"
execute "alter table users alter column chat_yahoo drop default;"
execute "alter table users alter column chat_msn drop default;"
execute "alter table users alter column chat_gtalk drop default;"


User.update_all("homepage = null", ["homepage = ?", "''::character varying"])
User.update_all("location = null", ["location = ?", "''::character varying"])
User.update_all("about = null", ["about = ?", "''::character varying"])
User.update_all("chat_aim = null", ["chat_aim = ?", "''::character varying"])
User.update_all("chat_yahoo = null", ["chat_yahoo = ?", "''::character varying"])
User.update_all("chat_msn = null", ["chat_msn = ?", "''::character varying"])
User.update_all("chat_gtalk = null", ["chat_gtalk = ?", "''::character varying"])


  end

  def self.down
  end
end
