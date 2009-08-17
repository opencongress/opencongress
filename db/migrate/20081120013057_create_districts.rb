class CreateDistricts < ActiveRecord::Migration
  def self.up
    create_table :districts do |t|
      t.integer :district_number
      t.integer :state_id

      t.timestamps
    end

    Person.rep.each do |p|
      state = State.find_by_abbreviation(p.state)
      District.find_or_create_by_state_id_and_district_number(state.id,p.district.to_i) if state
    end

  end

  def self.down
    drop_table :districts
  end
end
