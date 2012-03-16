class FormageddonIndexes < ActiveRecord::Migration
  def self.up
    add_index :formageddon_contact_steps, [ :formageddon_recipient_id, :formageddon_recipient_type ], :name => 'formageddon_cs_recipient_index'
    add_index :formageddon_threads, [ :formageddon_recipient_id, :formageddon_recipient_type ], :name => 'formageddon_t_recipient_index'
    add_index :formageddon_letters, :formageddon_thread_id
    add_index :formageddon_forms, :formageddon_contact_step_id
    add_index :formageddon_form_fields, :formageddon_form_id
    add_index :formageddon_form_captcha_images, :formageddon_form_id
    add_index :formageddon_delivery_attempts, :formageddon_letter_id
  end

  def self.down
    remove_index :formageddon_contact_steps, :name => 'formageddon_cs_recipient_index'
    remove_index :formageddon_threads, :name => 'formageddon_t_recipient_index'
    remove_index :formageddon_letters, :formageddon_thread_id
    remove_index :formageddon_forms, :formageddon_contact_step_id
    remove_index :formageddon_form_fields, :formageddon_form_id
    remove_index :formageddon_form_captcha_images, :formageddon_form_id
    remove_index :formageddon_delivery_attempts, :formageddon_letter_id
  end
end
