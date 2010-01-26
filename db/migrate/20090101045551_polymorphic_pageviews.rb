class PolymorphicPageviews < ActiveRecord::Migration
  def self.up
    # migration was run locally and dumped/imported into live
    
    add_column :page_views, :viewable_id, :integer
    add_column :page_views, :viewable_type, :string
    
    #execute "UPDATE page_views SET viewable_id=bill_id, viewable_type='Bill' WHERE type='BillView'"
    #execute "UPDATE page_views SET viewable_id=person_id, viewable_type='Person' WHERE (type='RepresentativeView' OR type='SenatorView')"
    #execute "UPDATE page_views SET viewable_id=subject_id, viewable_type='Subject' WHERE type='IssueView'"
    #execute "UPDATE page_views SET viewable_id=committee_id, viewable_type='Committee' WHERE type='CommitteeView'"
    #execute "UPDATE page_views SET viewable_id=sector_id, viewable_type='Sector' WHERE type='IndustryView'"

    #remove_column :page_views, :bill_id
    #remove_column :page_views, :person_id
    #remove_column :page_views, :subject_id
    #remove_column :page_views, :committee_id
    #remove_column :page_views, :sector_id
    #remove_column :page_views, :type
    
    add_index :page_views, [:viewable_id, :viewable_type, :created_at ]
    add_index :page_views, [:viewable_type, :created_at ]
    #add_index :page_views, :ip_address
    
    execute "ANALYZE page_views"
  end
  
  def self.down
    raise ActiveRecord::IrreversibleMigration, "Can't return to old page views code."
  end
end