class ContactCongressLetters < ActiveRecord::Migration
  def self.up
    create_table :contact_congress_letters do |t|
      t.integer :user_id
      t.integer :bill_id
      t.string :disposition
    end
    
    create_table :contact_congress_letters_formageddon_threads, :id => false do |t|
      t.integer :contact_congress_letter_id
      t.integer :formageddon_thread_id      
    end
  end

  def self.down
    drop_table :contact_congress_letters
    drop_table :contact_congress_letters_formageddon_threads
  end
end
