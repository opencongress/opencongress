class Amendment < ActiveRecord::Base
  belongs_to :bill
  has_many :actions
  has_many :roll_calls, :order => 'date'
  
  def display_number
    (/^s/.match(number) ? "S.Amdt." : "H.Amdt") + number[1..-1]
  end
end
