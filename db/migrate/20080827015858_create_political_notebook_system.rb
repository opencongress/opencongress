class CreatePoliticalNotebookSystem < ActiveRecord::Migration
  def self.up
    
    create_table "notebook_items", :force => true do |t|
      t.integer  "political_notebook_id"
      t.string   "type"
      t.string   "url"
      t.string   "title"
      t.string   "date"
      t.string   "source"
      t.text     "description"
      t.boolean  "is_internal"
      t.text     "embed"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "parent_id"
      t.integer  "size"
      t.integer  "width"
      t.integer  "height"
      t.string   "filename"
      t.string   "content_type"
      t.string   "thumbnail"
      t.string   "notebookable_type"
      t.integer  "notebookable_id"
    end

    create_table "political_notebooks", :force => true do |t|
      t.integer  "user_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
            
    add_column :privacy_options, :my_political_notebook, :integer, :default => 0
    
    execute "UPDATE privacy_options SET my_political_notebook=0"
  end

  def self.down
    drop_table :notebook_items
    drop_table :political_notebooks
    remove_column :privacy_options, :my_political_notebook
  end
end

