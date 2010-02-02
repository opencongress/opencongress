class AddDistrictCenters < ActiveRecord::Migration
  def self.up
    add_column :districts, :center_lat, :decimal, :precision => 15, :scale => 10
    add_column :districts, :center_lng, :decimal, :precision => 15, :scale => 10
    
    system(File.join(RAILS_ROOT, "bin", "fetch_district_centers.sh"))
    require File.join(RAILS_ROOT, 'bin', 'load_district_centers.rb')
  end

  def self.down
    remove_column :districts, :center_lat
    remove_column :districts, :center_lng
  end
end
