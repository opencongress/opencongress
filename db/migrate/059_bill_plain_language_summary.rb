class BillPlainLanguageSummary < ActiveRecord::Migration
  def self.up
    add_column :bills, :plain_language_summary, :text
  end

  def self.down
    remove_column :bills, :plain_language_summary
  end
end