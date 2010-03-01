class CreateBadCommentaries < ActiveRecord::Migration
  def self.up
      execute "CREATE TABLE bad_commentaries AS SELECT commentaries.url, commentaries.commentariable_id, commentaries.commentariable_type, commentaries.date FROM commentaries WHERE commentaries.is_ok = FALSE AND commentaries.status != 'PENDING'"
      execute "ALTER TABLE bad_commentaries ADD COLUMN id serial"
      execute "DELETE FROM commentaries WHERE commentaries.is_ok = FALSE AND commentaries.status != 'PENDING'"
      execute "REINDEX table commentaries"
  end

  def self.down
    drop_table :bad_commentaries
  end
end
