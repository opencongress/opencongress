class FeaturedPeopleText < ActiveRecord::Migration
  def self.up
    create_table :featured_people do |t| 
      t.column :person_id, :integer
      t.column :text, :text
      t.column :updated_at, :datetime
      t.column :created_at, :datetime
    end
    
    drop_table :most_viewed_person_texts
  end
  
  def self.down
    create_table :most_viewed_person_texts do |t|
      t.column :text, :text
      t.column :person_id, :integer
      t.column :role_type, :string      
      t.column :updated_at, :datetime
    end
    
    drop_table :featured_people    
  end
end