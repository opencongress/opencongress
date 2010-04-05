class CreateBadCommentaries < ActiveRecord::Migration
  def self.up
      execute "CREATE TABLE bad_commentaries AS SELECT commentaries.url, commentaries.commentariable_id, commentaries.commentariable_type, commentaries.date FROM commentaries WHERE commentaries.is_ok = FALSE AND commentaries.status != 'PENDING'"
      execute "ALTER TABLE bad_commentaries ADD COLUMN id serial"
      
      add_index :bad_commentaries, :url
      add_index :bad_commentaries, [:commentariable_id, :commentariable_type], :name => 'bad_commentariable_idx'
      
      execute "DELETE FROM commentaries WHERE commentaries.is_ok = FALSE AND commentaries.status != 'PENDING'"
      execute "REINDEX table commentaries"
  end

  def self.down
    remove_index :bad_commentaries, :name => 'bad_commentariable_idx'
    remove_index :bad_commentaries, :url
    drop_table :bad_commentaries
  end
end
