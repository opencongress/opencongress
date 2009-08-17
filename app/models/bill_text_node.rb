class BillTextNode < ActiveRecord::Base
  belongs_to :bill_text_version

  has_many :comments, :as => :commentable
  
  def display_object_name
    "Bill Text"
  end

  def ident
   "#{self.bill_text_version_id}-#{self.nid}"
  end


end
