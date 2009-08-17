class CreateMailingListItems < ActiveRecord::Migration
  def self.up
    create_table :mailing_list_items do |t|
      t.string :mailable_type
      t.integer :mailable_id
      t.integer :user_mailing_list_id

      t.timestamps
    end
  end

  def self.down
    drop_table :mailing_list_items
  end
end
