class MailingListItem < ActiveRecord::Base
  belongs_to :user_mailing_list
  belongs_to :mailable, :polymorphic => true
  
  named_scope :people, :conditions => ["mailable_type = 'Person'"]
  named_scope :bills, :conditions => ["mailable_type = 'Bill'"]
  
end
