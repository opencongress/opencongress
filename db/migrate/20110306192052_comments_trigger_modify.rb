class CommentsTriggerModify < ActiveRecord::Migration
  def self.up
    execute "drop TRIGGER comments_tsvectorupdate  ON comments"
    
    execute "CREATE TRIGGER comments_tsvectorupdate BEFORE INSERT ON comments FOR EACH ROW EXECUTE PROCEDURE tsearch2(fti_names, comment);" 
  end

  def self.down
  end
end
