class CreateFormageddonTables < ActiveRecord::Migration
  def self.up    
    create_table :formageddon_contact_steps do |t|
      t.integer :formageddon_recipient_id
      t.string :formageddon_recipient_type
      t.integer :step_number
      t.string :command
    end
    
    create_table :formageddon_forms do |t|
      t.integer :formageddon_contact_step_id
      t.integer :form_number
      t.string :success_string
    end

    create_table :formageddon_form_fields do |t|
      t.integer :formageddon_form_id
      t.integer :field_number
      t.string :name
      t.string :value
    end
    
    create_table :formageddon_threads do |t|
      t.integer :formageddon_recipient_id
      t.string :formageddon_recipient_type

      t.string :sender_title
      t.string :sender_first_name
      t.string :sender_last_name
      t.string :sender_address1
      t.string :sender_address2
      t.string :sender_city
      t.string :sender_state
      t.string :sender_zip5
      t.string :sender_zip4
      t.string :sender_phone
      t.string :sender_email
      t.boolean :is_public

      t.integer :formageddon_sender_id
      t.string :formageddon_sender_type
      
      t.timestamps
    end    
    
    create_table :formageddon_letters do |t|
      t.integer :formageddon_thread_id
      t.string :direction
      t.string :status
      t.string :issue_area
      t.string :subject
      t.text :message
      
      t.timestamps
    end
  end
  
  def self.down
    drop_table :formageddon_contact_steps
    drop_table :formageddon_forms
    drop_table :formageddon_form_fields
    drop_table :formageddon_threads
    drop_table :formageddon_letters
  end
end
