class Amendment < ActiveRecord::Base
  belongs_to :bill
  has_many :actions
  has_many :roll_calls, :order => 'date'
  
  def display_number
    (/^s/.match(number) ? "S.Amdt." : "H.Amdt") + number[1..-1]
  end
  
  def offered_date_short
    Time.at(offered_date).utc.strftime("%b ") + Time.at(offered_date).utc.day.ordinalize    
  end
  
  def thomas_url
    "http://hdl.loc.gov/loc.uscongress/legislation.#{bill.session}#{number[0...1]}amdt#{number[1..-1]}"
  end
end
