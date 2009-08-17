class Lastaction < ActiveRecord::Migration
  def self.up
    #I'm not sure this should even be a migration, but it seems like a
    #good place to put code of this nature.
    bills = Bill.find(:all)
    Bill.transaction do 
      bills.each do |b|
        b.lastaction = b.last_action
        b.save
      end
    end
  end

  def self.down
    bills = Bill.find(:all)
    Bill.transaction do
      bills.each do |b|
        b.lastaction = nil
        b.save
      end
    end
  end
end
