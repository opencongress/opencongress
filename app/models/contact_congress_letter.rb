class ContactCongressLetter < ActiveRecord::Base 
  has_many :formageddon_threads, :through => :contact_congress_letters_formageddon_threads, :class_name => 'Formageddon::FormageddonThread'
  has_many :contact_congress_letters_formageddon_threads
  
  belongs_to :bill
  belongs_to :user
  
  has_many :comments, :as => :commentable
  
  def to_param
    subject = formageddon_threads.first.formageddon_letters.first.subject
    subject.blank? ? "#{id}" : "#{id}-#{subject.gsub(/[^a-z0-9]+/i, '-')}"
  end
end