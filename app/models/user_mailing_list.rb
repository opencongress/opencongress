class UserMailingList < ActiveRecord::Base

  has_many :mailing_list_items
  belongs_to :user

  OK=1
  BOUNCED=2
  DISABLED=3

  named_scope :all_ok, :conditions => ["user_mailing_lists.status = ?", OK]
  named_scope :all_admin, :include => [{:user => :user_role}], :conditions => ["user_roles.name = ?", "Administrator"]

  def self.find_or_create_from_user(user)
    if user.user_mailing_list.blank?
      logger.warn "#{user.id}"
      uml = UserMailingList.new({:status => OK})
      uml.user_id = user.id
      uml.save
      uml
    else
      user.user_mailing_list
    end
  end

  def already_contains?(object)
    self.mailing_list_items.count(:conditions =>["mailing_list_items.mailable_id = ? and mailing_list_items.mailable_type = ?", object.id, object.class.to_s]) > 0
  end


  def self.send_all_updates(since = nil)
    if RAILS_ENV=="production"
      self.all_ok.each do |s|
        s.send_message(since)
      end
    else
      self.all_admin.all_ok.each do |s|
        s.send_message(since)
      end
    end    
  end
    

  def send_message(since = nil)
    return unless self.status == OK
    people = []
    these_people = self.mailing_list_items.people
    these_people.each do |tp|
      people << tp.mailable.recent_activity_mini_list(since)
    end
    people = people.flatten.compact
    if people.length > 0
      people = these_people.collect{|p| p.mailable}
    else
      people = []
    end
    bills = []  
    these_bills = self.mailing_list_items.bills
    these_bills.each do |tp|
      bills << tp.mailable.recent_activity_mini_list(since)
    end
    bills = bills.flatten.compact
    if bills.length > 0
      bills = these_bills.collect{|p| p.mailable}
    else
      bills = []
    end
    
    unless people.empty? && bills.empty?
      MiniMailingList.deliver_standard_message(user,bills,people)
    end
    self.update_attribute(:last_processed, Time.now)
    
  end
  
end
