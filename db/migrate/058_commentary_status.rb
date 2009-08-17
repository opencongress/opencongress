class CommentaryStatus < ActiveRecord::Migration
  def self.up
    add_column :commentaries, :status, :string
    add_column :commentaries, :contains_term, :string
    
    execute "UPDATE commentaries SET status='OK'"
  end

  def self.down
    remove_column :commentaries, :status
    remove_column :commentaries, :contains_term
  end
end