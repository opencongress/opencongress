class Gossip < ActiveRecord::Base
  validates_presence_of :email, :name, :tip
  set_table_name 'gossip'

  def Gossip.latest(number = 10)
    Gossip.find :all, :limit => number, :order => "created_at desc", :conditions => 'approved = true'
  end

  def Gossip.frontpage(number = 4)
    Gossip.find :all, :limit => number, :order => "created_at desc", :conditions => 'frontpage = true'
  end

  def Gossip.today
    Gossip.find :all, :order => "created_at desc", :conditions => ['published = true && created_at > ?', Time.now.beginning_of_day] 
  end

  def Gossip.for_admin
    Gossip.find :all, :order => "frontpage desc, approved desc, updated_at, created_at"
  end

  def tip_html
    return RedCloth.new(tip).to_html
  end

  def formatted_date
    created_at.strftime "%b %e, %y"
  end

end
