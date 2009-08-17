class IssueCache < ActiveRecord::Migration
  def self.up
    remove_column :subjects, :bill_id
    add_column :subjects, :bill_count, :integer
    Subject.reset_column_information
    Subject.find(:all).each do |subject|
      subject.bill_count = subject.bills.size 
      subject.save
    end
  end

  def self.down
    add_column :subjects, :bill_id, :integer
    remove_column :subjects, :bill_count
  end
end
