class FrontpageHot < ActiveRecord::Migration
  def self.up
    add_column :bills, :is_frontpage_hot, :boolean
    execute "UPDATE bills SET is_frontpage_hot='f'"
    
    hot_bills = []
    hot_bills << Bill.find(:first, :conditions => "bill_type='h' and session=111 and number=3200")
    hot_bills << Bill.find(:first, :conditions => "bill_type='h' and session=111 and number=2454")
    hot_bills << Bill.find(:first, :conditions => "bill_type='h' and session=111 and number=1207")
    hot_bills << Bill.find(:first, :conditions => "bill_type='h' and session=111 and number=2749")
    hot_bills << Bill.find(:first, :conditions => "bill_type='s' and session=111 and number=560")
    hot_bills << Bill.find(:first, :conditions => "bill_type='h' and session=111 and number=1")
    
    hot_bills.each do |b|
      if b
        b.is_frontpage_hot = true
        b.save
      end
    end
  end

  def self.down
    remove_column :bills, :is_frontpage_hot
  end
end
