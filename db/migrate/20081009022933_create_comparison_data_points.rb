class CreateComparisonDataPoints < ActiveRecord::Migration
  def self.up
    create_table :comparison_data_points do |t|
      t.integer :comparison_id
      t.integer :comp_value
      t.integer :comp_indx

      t.timestamps
    end
    Comparison.run_senate
    Comparison.run_house
  end

  def self.down
    drop_table :comparison_data_points
  end
end
