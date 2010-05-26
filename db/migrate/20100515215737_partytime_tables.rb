class PartytimeTables < ActiveRecord::Migration
  def self.up
    create_table :fundraisers, :force => true do |t|
      t.integer :sunlight_id
      t.integer :person_id
      t.string :host
      t.string :beneficiaries
      t.timestamp :start_time
      t.timestamp :end_time
      t.string :venue
      t.string :entertainment_type
      t.string :venue_address1
      t.string :venue_address2 
      t.string :venue_city
      t.string :venue_state
      t.string :venue_zipcode	
      t.string :venue_website	
      t.string :contributions_info
      t.string :latlong	
      t.string :rsvp_info	
      t.string :distribution_payer
      t.string :make_checks_payable_to
      t.string :checks_payable_address
      t.string :committee_id
    end
    
    add_index :fundraisers, :person_id
  end

  def self.down
    drop_table :fundraisers
  end
end
