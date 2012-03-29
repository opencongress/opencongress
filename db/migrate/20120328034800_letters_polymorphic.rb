class LettersPolymorphic < ActiveRecord::Migration
  def self.up
    add_column :contact_congress_letters, :contactable_id, :integer
    add_column :contact_congress_letters, :contactable_type, :string
    
    add_index :contact_congress_letters, [ :contactable_id, :contactable_type ], :name => 'contactable_index'
    
    ContactCongressLetter.all.each do |l|
      l.contactable_id = l.bill_id
      l.contactable_type = 'Bill'
      l.save
    end
    
    remove_column :contact_congress_letters, :bill_id
  end

  def self.down
    add_column :contact_congress_letters, :bill_id, :integer
    
    ContactCongressLetter.all.each do |l|
      l.bill_id = l.contactable_id
    end
    
    remove_index :name => 'contactable_index'

    remove_column :contact_congress_letters, :contactable_id
    remove_column :contact_congress_letters, :contactable_type
  end
end
