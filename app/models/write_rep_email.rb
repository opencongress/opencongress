class WriteRepEmail < ActiveRecord::Base
  belongs_to :user
  belongs_to :person
  has_many :write_rep_email_msgids
  
  validates_presence_of :prefix, :fname, :lname, :msg, :email, :state
  validates_presence_of :address, :city, :state, :zip5
end