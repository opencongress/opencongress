class ActionType < ActiveRecord::Migration
  def self.up
    #This is a helluva migration.  Takes a long time.
    add_column :actions, :type, :string
    ba = Action.find(:all, :conditions => ["bill_id is not null"])
    aa = Action.find(:all, :conditions => ["amendment_id is not null"])
    ba.each { |b| b.type = "BillAction" }
    aa.each { |a| a.type = "AmendmentAction" }
    Action.transaction do  
      ba.each { |a| a.save }
      aa.each { |a| a.save }
    end
  end

  def self.down
    remove_column :actions, :type
  end
end
