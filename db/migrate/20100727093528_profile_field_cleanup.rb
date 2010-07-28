class ProfileFieldCleanup < ActiveRecord::Migration
  def self.up
    execute "update users set full_name=NULL where full_name='[Click to Edit]'"
    execute "update users set about=NULL where about='[Click to Edit]'"
    execute "update users set homepage=NULL where homepage='[Click to Edit]'"
    execute "update users set location=NULL where location='[Click to Edit]'"
    execute "update users set chat_aim=NULL where chat_aim='[Click to Edit]'"
    execute "update users set chat_yahoo=NULL where chat_yahoo='[Click to Edit]'"
    execute "update users set chat_msn=NULL where chat_msn='[Click to Edit]'"
    execute "update users set chat_icq=NULL where chat_icq='[Click to Edit]'"
    execute "update users set chat_gtalk=NULL where chat_gtalk='[Click to Edit]'"
    
    add_index :comments, :user_id
    
    execute "CREATE INDEX users_lower_login_index ON users (LOWER(login))"
    execute "CREATE INDEX users_lower_email_index ON users (LOWER(email))"    
  end

  def self.down
    remove_index :comments, :user_id    

    execute "DROP INDEX users_lower_login_index"
    execute "DROP INDEX users_lower_email_index"
    
  end
end
