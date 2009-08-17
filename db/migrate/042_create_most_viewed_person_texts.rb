class CreateMostViewedPersonTexts < ActiveRecord::Migration

  def self.up
    create_table :most_viewed_person_texts do |t|
      t.column :text, :text
      t.column :person_id, :integer
      t.column :role_type, :string      
      t.column :updated_at, :datetime
    end
  end

  def self.down
    drop_table :most_viewed_person_texts
  end
end
