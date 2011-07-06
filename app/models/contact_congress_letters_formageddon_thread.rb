class ContactCongressLettersFormageddonThread < ActiveRecord::Base  
  belongs_to :formageddon_thread
  belongs_to :contact_congress_letter
end