class OpensecretsApi < ActiveRecord::Migration
  def self.up
    add_column :people_sectors, :cycle, :string
    rename_column :people_sectors, :revision_date, :updated_at
    
    # all of the current data is for the 2006 cycle
    PersonSector.find(:all).each do |ps|
      ps.cycle = '2006'
      ps.save
    end
    
    create_table :people_cycle_contributions do |t|
      t.column :person_id, :integer      
      t.column :total_raised, :integer
      t.column :top_contributor_id, :integer
      t.column :top_contributor_amount, :integer
      t.column :cycle, :string
      t.column :updated_at, :timestamp      
    end
    
    Person.all_sitting.each do |p|
      pcc = PersonCycleContribution.new
      pcc.total_raised = p.money_raised
      pcc.top_contributor_id = p.top_contributor_id
      pcc.top_contributor_amount = p.top_contribution
      pcc.cycle = '2006'
      pcc.person = p
      pcc.save
    end
    
    remove_column :people, :money_raised
    remove_column :people, :money_raised_at
    remove_column :people, :top_contributor_id
    remove_column :people, :top_contribution
    remove_column :people, :top_contributor_at
    
    add_index :people_sectors, :person_id
    add_index :people_sectors, :sector_id
    add_index :people_cycle_contributions, :person_id
    
    Person.reset_column_information
  end
  
  def self.down
    remove_column :people_sectors, :cycle
    rename_column :people_sectors, :updated_at, :revision_date
    
    drop_table :people_cycle_contributions
    
    add_column :people, :money_raised, :integer
    add_column :people, :money_raised_at, :datetime
    add_column :people, :top_contributor_id, :integer
    add_column :people, :top_contribution, :integer
    add_column :people, :top_contributor_at, :datetime
    
    remove_index :people_sectors, :person_id
    remove_index :people_sectors, :sector_id
    remove_index :people_cycle_contributions, :person_id
  end 
end