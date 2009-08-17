class PersonSunlightlabsFields < ActiveRecord::Migration
  def self.up
    add_column :people, :website, :string
    add_column :people, :congress_office, :string
    add_column :people, :phone, :string
    add_column :people, :fax, :string
    add_column :people, :contact_webform, :string    
    add_column :people, :sunlight_nickname, :string    
  end

  def self.down
    remove_column :people, :website
    remove_column :people, :congress_office
    remove_column :people, :phone
    remove_column :people, :fax
    remove_column :people, :contact_webform
    remove_column :people, :sunlight_nickname
  end
end
