class AddRolesView < ActiveRecord::Migration
  def self.up
    execute("CREATE OR REPLACE VIEW v_current_roles AS
    SELECT states.id as state_id, roles.id as role_id, people.id as person_id,
    roles.role_type as role_type
    from people
      inner join roles ON roles.person_id = people.id
      inner join states on people.state = states.abbreviation
    WHERE roles.enddate > current_timestamp")
  end

  def self.down
    execute("drop view v_current_roles")
  end
end
