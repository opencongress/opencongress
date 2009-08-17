class AddCategoryToNotebookItems < ActiveRecord::Migration
  def self.up
    add_column :notebook_items, :hot_bill_category_id, :integer
  end

  def self.down
    remove_column :notebook_items, :hot_bill_category_id
  end
end
