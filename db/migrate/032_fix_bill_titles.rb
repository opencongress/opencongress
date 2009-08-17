class FixBillTitles < ActiveRecord::Migration
  def self.up
    remove_column :bill_titles, :title
    add_column :bill_titles, :title, :text
    remove_column :bills, :summary
    add_column :bills, :summary, :text
  end

  def self.down
    remove_column :bill_titles, :title
    add_column :bill_titles, :title, :string
    remove_column :bills, :summary
    add_column :bills, :summary, :string
  end
end
