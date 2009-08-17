class SummaryToText < ActiveRecord::Migration
  def self.up
    remove_column :bills, :summary
    add_column :bills, :summary, :text
  end

  def self.down
    remove_column :bills, :summary
    add_column :bills, :summary, :string
  end
end
