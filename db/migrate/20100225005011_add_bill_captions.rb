class AddBillCaptions < ActiveRecord::Migration
  def self.up
      add_column :bills, :caption, :text
  end

  def self.down
    remove_column :bills, :caption
  end
end
