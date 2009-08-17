class CommentaryRefactor < ActiveRecord::Migration
  def self.up    
    add_column :commentaries, :is_news, :boolean
    add_column :commentaries, :is_ok, :boolean, :default => false
    
    # just used to make this migration faster 
    add_index :commentaries, :commentary_type
    add_index :commentaries, :status
    
    execute "VACUUM ANALYZE commentaries"
    
    execute "UPDATE commentaries SET is_news='t' WHERE commentary_type='news'"
    execute "UPDATE commentaries SET is_news='f' WHERE commentary_type='blog'"
    
    remove_index :commentaries, [:date, :commentary_type]
    remove_column :commentaries, :commentary_type

    execute "UPDATE commentaries SET is_ok='t' WHERE status='OK'"
    execute "UPDATE commentaries SET is_ok='f' WHERE status <> 'OK'"

    add_index :commentaries, [:date, :is_ok, :is_news]
    
    execute "VACUUM ANALYZE commentaries"
  end
  
  def self.down
    add_column :commentaries, :commentary_type, :string
    
    execute "UPDATE commentaries SET commentary_type='news' WHERE is_news='t'"
    execute "UPDATE commentaries SET commentary_type='blog' WHERE is_news='f'"
    
    remove_index :commentaries, [:date, :is_ok, :is_news]
    
    remove_column :commentaries, :is_news
    remove_column :commentaries, :is_ok
    
    add_index :commentaries, [:date, :commentary_type]
    
    execute "VACUUM ANALYZE commentaries"
  end
end