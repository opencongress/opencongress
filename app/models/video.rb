class Video < ActiveRecord::Base 
  belongs_to :person
  belongs_to :bill
  
  def atom_id_as_entry
    "tag:opencongress.org,#{created_at.strftime("%Y-%m-%d")}:/video/#{id}"
  end
end