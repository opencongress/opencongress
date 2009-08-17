class UpdateBillTsearch < ActiveRecord::Migration
  def self.up
    Bill.find(:all, :conditions => "session=110").each { |b| b.save }
  end

  def self.down
  end
end