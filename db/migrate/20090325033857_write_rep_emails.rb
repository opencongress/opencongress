class WriteRepEmails < ActiveRecord::Migration
  def self.up
    create_table :write_rep_emails do |t|
      t.integer :user_id
      t.string :prefix
      t.string :fname
      t.string :lname
      t.string :address
      t.string :zip5
      t.string :zip4
      t.string :city   
      t.string :state
      t.string :district
      t.integer :person_id
      t.string :email
      t.string :phone
      t.string :subject
      t.text :msg
      t.string :result
      t.string :ip_address

      t.timestamps
    end
    
    create_table :write_rep_email_msgids do |t|
      t.integer :write_rep_email_id
      t.integer :person_id
      t.string :status
      t.integer :msgid
      
      t.timestamps
    end
    
    add_column :people, :watchdog_id, :string
  end

  def self.down
    drop_table :write_rep_emails
    drop_table :write_rep_email_msgids
    
    remove_column :people, :watchdog_id
  end
end
