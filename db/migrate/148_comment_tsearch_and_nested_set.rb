class CommentTsearchAndNestedSet < ActiveRecord::Migration
  def self.up
    # convert 'comments' to a nested_set
    add_column :comments, :rgt, :integer, :default => nil
    add_column :comments, :lft, :integer, :default => nil
    add_column :comments, :root_id, :integer

    execute "UPDATE comments SET parent_id=NULL WHERE parent_id=0"
    
    # Convert existing tree to nested set with scope
    Comment.rebuild!
    Comment.roots.each do |r|
      r.children.each do |c|
        c.update_attribute(:root_id, r.id)
      end
      r.update_attribute(:root_id, r.id)
    end

    # now make it searchable
    execute "ALTER TABLE comments ADD COLUMN fti_names tsvector;"
    execute "CREATE INDEX comments_fti_names_index ON comments USING gist(fti_names);"
    execute "UPDATE comments SET fti_names=to_tsvector('default', coalesce(comment,''));"
    execute "CREATE TRIGGER comments_tsvectorupdate BEFORE UPDATE OR INSERT ON comments FOR EACH ROW EXECUTE PROCEDURE tsearch2(fti_names, comment);" 

    # there are some unnecessary indexes on the table
    #execute "DROP INDEX comments_commentable_id_index"
    #execute "DROP INDEX index_comments_on_commentable_id"
  end

  def self.down
    remove_column :comments, :lft
    remove_column :comments, :rgt
    remove_column :comments, :root_id
    
    execute "DROP TRIGGER comments_tsvectorupdate ON sectors;"
    execute "DROP INDEX comments_fti_names_index"
  end
end

