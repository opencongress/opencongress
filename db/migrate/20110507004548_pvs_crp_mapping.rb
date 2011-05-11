class PvsCrpMapping < ActiveRecord::Migration
  def self.up
    create_table :pvs_category_mappings do |t|
      t.integer :pvs_category_id
      t.integer :pvs_category_mappable_id
      t.string :pvs_category_mappable_type
    end
  end

  def self.down
    drop_table :pvs_category_mappings
  end
end
